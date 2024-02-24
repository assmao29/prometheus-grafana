#!/bin/bash

sudo useradd --no-create-home -s /bin/false prometheus

sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

sudo cd /tmp
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.13.1/prometheus-2.13.1.linux-amd64.tar.gz
sudo tar xvzf prometheus-2.13.1.linux-amd64.tar.gz
sudo mv prometheus-2.13.1.linux-amd64/* /var/lib/prometheus/

cd
sudo mv /var/lib/prometheus/prometheus.yml /etc/prometheus/

sudo ln -s /var/lib/prometheus/prometheus /usr/local/bin/prometheus

sudo tee /usr/lib/systemd/system/prometheus.service<<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/var/lib/prometheus/consoles \
--web.console.libraries=/var/lib/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable --now prometheus.service