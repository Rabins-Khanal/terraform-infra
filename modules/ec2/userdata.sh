#!/bin/bash
set -xe  # prints commands and exits on error

echo "Running user-data script..." > /var/log/user-data.log

if [ -f /etc/debian_version ]; then
  apt-get update -y
  apt-get install -y apache2 php php-mysql libapache2-mod-php unzip
  systemctl enable apache2
  systemctl start apache2
  echo "LAMP installed" >> /var/log/user-data.log
fi

REGION="ap-south-1"
cd /tmp
wget https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl enable codedeploy-agent || true
systemctl start codedeploy-agent || true
echo "CodeDeploy agent installed" >> /var/log/user-data.log
