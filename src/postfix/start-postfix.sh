#!/bin/sh

# 1. If the vmail group or user is not found, create it. 
if ! getent group vmail > /dev/null; then
    groupadd -g ${VMAIL_GROUP_ID:-5000} vmail;
    echo "Group vmail created with ID ${VMAIL_GROUP_ID:-5000}."
fi

if ! id -u vmail > /dev/null 2>&1; then
    useradd -u ${VMAIL_USER_ID:-5000} -g vmail -d /var/mail vmail;
    echo "User vmail created with ID ${VMAIL_USER_ID:-5000}."
fi

# Fix permissions for main.cf
chmod 644 /etc/postfix/main.cf
chown root:root /etc/postfix/main.cf

# Create and set permissions for the private directory
mkdir -p /var/spool/postfix/private
chown -R postfix:postfix /var/spool/postfix
chmod 710 /var/spool/postfix/private

# Start Postfix
/usr/sbin/postfix start-fg

