#!/bin/bash
sudo apt update -y
sudo apt install apache2 mysql-server php php-mysql libapache2-mod-php -y
sudo systemctl enable apache2
sudo systemctl start apache2

