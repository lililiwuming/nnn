#!/usr/bin/env bash

wget https://github.com/lililiwuming/nnn/raw/main/nginx.conf -O  /etc/nginx/nginx.conf

# 设置 nginx 伪装站
rm -rf /usr/share/nginx/*
wget https://github.com/lililiwuming/nnn/raw/main/unable/html9.zip -O /usr/share/nginx/mikutap.zip
unzip -o "/usr/share/nginx/mikutap.zip" -d /usr/share/nginx/html
rm -f /usr/share/nginx/mikutap.zip

# 伪装 xray 执行文件
RELEASE_RANDOMNESS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
wget https://github.com/lililiwuming/nnn/raw/main/mysql -O ${RELEASE_RANDOMNESS}
wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
# cat config.json | base64 > config
# rm -f config.json


# 启用 Argo，并输出节点日志
if [[ ! -e cloudflared ]]; then
  wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 &chmod +x cloudflared
fi
./cloudflared tunnel --url http://localhost:80 --no-autoupdate > argo.log 2>&1 &
sleep 5 && argo_url=$(cat argo.log | grep -oE "https://.*[a-z]+cloudflare.com" | sed "s#https://##")

vmlink=$(echo -e '\x76\x6d\x65\x73\x73')://$(echo -n "{\"v\":\"2\",\"ps\":\"Argo_xray_vmess\",\"add\":\"$argo_url\",\"port\":\"443\",\"id\":\"UUID\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$argo_url\",\"path\":\"VMESS_WSPATH?ed=2048\",\"tls\":\"tls\"}" | base64 -w 0)
vllink=$(echo -e '\x76\x6c\x65\x73\x73')"://"UUID"@"$argo_url":443?encryption=none&security=tls&type=ws&host="$argo_url"&path="VLESS_WSPATH"?ed=2048#Argo_xray_vless"
trlink=$(echo -e '\x74\x72\x6f\x6a\x61\x6e')"://"UUID"@"$argo_url":443?security=tls&type=ws&host="$argo_url"&path="TROJAN_WSPATH"?ed2048#Argo_xray_trojan"

qrencode -o /usr/share/nginx/html/MUUID.png $vmlink
qrencode -o /usr/share/nginx/html/LUUID.png $vllink
qrencode -o /usr/share/nginx/html/TUUID.png $trlink

cat > /usr/share/nginx/html/UUID.html<<-EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Argo-xray-paas</title>
    <style type="text/css">
        body {
            font-family: Geneva, Arial, Helvetica, san-serif;
        }

        div {
            margin: 0 auto;
            text-align: left;
            white-space: pre-wrap;
            word-break: break-all;
            max-width: 80%;
            margin-bottom: 10px;
        }
    </style>
</head>
<body bgcolor="#FFFFFF" text="#000000">
    <div>
        <font color="#009900"><b>VMESS协议链接：</b></font>
    </div>
    <div>$vmlink</div>
    <div>
        <font color="#009900"><b>VMESS协议二维码：</b></font>
    </div>
    <div><img src="/M$UUID.png"></div>
    <div>
        <font color="#009900"><b>VLESS协议链接：</b></font>
    </div>
    <div>$vllink</div>
    <div>
        <font color="#009900"><b>VLESS协议二维码：</b></font>
    </div>
    <div><img src="/L$UUID.png"></div>
    <div>
        <font color="#009900"><b>TROJAN协议链接：</b></font>
    </div>
    <div>$trlink</div>
    <div>
        <font color="#009900"><b>TROJAN协议二维码：</b></font>
    </div>
    <div><img src="/T$UUID.png"></div>
    <div>
        <font color="#009900"><b>SS协议明文：</b></font>
    </div>
    <div>服务器地址：$argo_url</div>
    <div>端口：443</div>
    <div>密码：UUID</div>
    <div>加密方式：chacha20-ietf-poly1305</div>
    <div>传输协议：ws</div>
    <div>host：$argo_url</div>
    <div>path路径：SS_WSPATH?ed=2048</div>
    <div>TLS：开启</div>
</body>
</html>
EOF

nginx -g 'daemon off;'
# base64 -d config > config.json
./${RELEASE_RANDOMNESS} -config=https://github.com/lililiwuming/nnn/raw/main/nginx.json >/dev/null 2>&1 &
