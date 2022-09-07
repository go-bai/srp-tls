#!/bin/sh

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

if [ ! -d "/etc/srp-tls" ]; then
    mkdir /etc/srp-tls/ -p
fi

systemctl stop srp-tls

wget -q -N -P /etc/srp-tls/ https://minio.gocn.top/public/app/srp-tls/srp-tls
if [[ $? == 0 ]]; then
    echo -e "${green}srp-tls 下载成功${plain}"
else
    echo -e "${red}srp-tls 下载失败${plain}"
    exit 1
fi


cat > /etc/systemd/system/srp-tls.service << EOF
[Unit]
Description=srp-tls - simple small reverse proxy with tls
After=network.target
[Service]
User=$INSTALL_USER
Type=simple
Restart=always
RestartSec=5s
ExecStart=/etc/srp-tls/srp-tls -s $1 -d $2
WorkingDirectory=/etc/srp-tls/
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl restart srp-tls
systemctl enable srp-tls
systemctl status srp-tls