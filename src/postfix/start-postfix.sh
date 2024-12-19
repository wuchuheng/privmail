#!/bin/sh

groupadd -g 5000 vmail;
useradd -u 5000 -g vmail -d /var/mail vmail;

# Fix permissions for main.cf
chmod 644 /etc/postfix/main.cf
chown root:root /etc/postfix/main.cf

# Create and set permissions for the private directory
mkdir -p /var/spool/postfix/private
chown -R postfix:postfix /var/spool/postfix
chmod 710 /var/spool/postfix/private

# Start Postfix
/usr/sbin/postfix start-fg

