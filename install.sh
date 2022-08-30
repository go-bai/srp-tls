#!/bin/sh

if [ ! -d "/etc/srp-tls" ]; then
    mkdir /etc/srp-tls/ -p
fi

go mod tidy && go build -o srp-tls
rm -f /etc/srp-tls/srp-tls
mv srp-tls /etc/srp-tls/

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