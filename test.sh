#!/bin/bash

sudo useradd --no-create-home -s /bin/false prometheus

cd /tmp
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.30.3/prometheus-2.30.3.linux-amd64.tar.gz
sudo tar xvzf prometheus-2.30.3.linux-amd64.tar.gz

sudo mv prometheus-2.30.3.linux-amd64/{prometheus,promtool} /usr/local/bin/

sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

sudo mkdir /etc/prometheus

sudo mv prometheus-2.30.3.linux-amd64/prometheus.yml /etc/prometheus/

sudo nano /etc/prometheus/prometheus.yml

if [ -f /etc/systemd/system/prometheus.service ]; then
  echo "The Prometheus configuration file already exists."
else
sudo touch /etc/systemd/system/prometheus.service
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/usr/local/bin/consoles \
  --web.console.libraries=/usr/local/bin/console_libraries

[Install]
WantedBy=multi-user.target
EOF
fi
sudo systemctl daemon-reload

sudo systemctl start prometheus

