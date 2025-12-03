#!/bin/bash
set -e

# install apache/php
apt-get update -y || yum update -y
# install LAMP stack depending on distro; here's ubuntu example
if [ -f /etc/debian_version ]; then
  apt-get install -y apache2 php php-mysql libapache2-mod-php unzip
  systemctl enable apache2
  systemctl start apache2
fi

# Install CodeDeploy agent (region-specific endpoint)
REGION="ap-south-1"  # change to your region if different
cd /tmp
wget https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl enable codedeploy-agent || true
systemctl start codedeploy-agent || true
