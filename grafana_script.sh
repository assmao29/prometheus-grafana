#!/bin/bash

sudo tee  /etc/yum.repos.d/grafana.repo<<EOF

# Create a new file and insert the content
#cat > /etc/yum.repos.d/grafana.repo <<EOF

[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

echo "The Grafana repository configuration file has been created at /etc/yum.repos.d/grafana.repo."

sudo dhclient
sudo yum update
sudo yum install -y grafana

sudo systemctl enable --now grafana-server