#!/bin/bash -e
if [ $# -ne 1 ]; then
    echo "Usage: $0 <user>"
    exit 1
fi
user="$1"

mkdir -p /usr/local/{include,lib/x86_64-linux-gnu,share/{man,wayland-sessions}}/
docker build . -t dwl-builder
docker run --rm --name dwl -dp 80:8000 dwl-builder
curl localhost | tar -xC /
ldconfig

cp -a ./launch.sh /usr/local/bin/dwl_launcer.sh

cat > /etc/systemd/system/dwl.service <<EOF
[Unit]
Description=dwl
After=graphical.target
Requires=graphical.target

[Service]
Type=simple
User=$user
WorkingDirectory=\$HOME
ExecStart=/usr/local/bin/dwl_launcer.sh

[Install]
WantedBy=graphical.target
EOF

systemctl daemon-reload
systemctl enable --now dwl.service
