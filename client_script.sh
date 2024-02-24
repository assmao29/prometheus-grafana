#!/bin/bash

sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.0.0-rc.1/node_exporter-1.0.0-rc.1.linux-amd64.tar.gz
sudo tar -xzf node_exporter-1.0.0-rc.1.linux-amd64.tar.gz

sudo useradd -rs /bin/false nodeuser
sudo mv node_exporter-1.0.0-rc.1.linux-amd64/node_exporter /usr/local/bin/

# Check if the file already exists
if [ -f /etc/systemd/system/node_exporter.service ]; then
  echo "The Node Exporter systemd unit file already exists."
else
  # Create a new file and insert the content
  sudo tee /etc/systemd/system/node_exporter.service<<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nodeuser
Group=nodeuser
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
  echo "The Node Exporter systemd unit file has been created successfully."
fi

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl status node_exporter

sudo systemctl enable node_exporter