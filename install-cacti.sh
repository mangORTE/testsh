#!/bin/sh

apt update && apt upgrade
# Install Apache for cacti
apt install apache2
systemctl enable --now apache2
# Install PHP and MariaDB
apt install php php-{mysql,curl,net-socket,gd,intl,pear,imap,memcache,pspell,tidy,xmlrpc,snmp,mbstring,gmp,json,xml,common,ldap} -y
apt install libapache2-mod-php -y
# Configure PHP memory and execution time





