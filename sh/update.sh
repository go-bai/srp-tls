#!/bin/sh

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

systemctl stop srp-tls

wget -q -N -P /etc/srp-tls/ https://minio.gocn.top/public/app/srp-tls/srp-tls
if [[ $? == 0 ]]; then
    echo -e "${green}srp-tls 下载成功${plain}"
else
    echo -e "${red}srp-tls 下载失败${plain}"
    exit 1
fi

systemctl start srp-tls
systemctl status srp-tls
