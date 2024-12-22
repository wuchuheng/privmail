#!/bin/sh

# 1. If the vmail group or user is not found, create it. 
if ! id -u vmail > /dev/null 2>&1; then
    useradd -u ${VMAIL_USER_ID:-5000} -g vmail -d /var/mail vmail;
    echo "User vmail created with ID ${VMAIL_USER_ID:-5000}."
fi

if ! getent group vmail > /dev/null; then
    groupadd -g ${VMAIL_GROUP_ID:-5000} vmail;
    echo "Group vmail created with ID ${VMAIL_GROUP_ID:-5000}."
fi

# Fix permissions for main.cf
chmod 644 /etc/postfix/main.cf
chown root:root /etc/postfix/main.cf

# Create and set permissions for the private directory
mkdir -p /var/spool/postfix/private
chmod 710 /var/spool/postfix/private
chown -R postfix:postfix /var/spool/postfix
# 3. Set correct ownership for Postfix directories
chown -R postfix:postdrop /var/spool/postfix/public
chown -R root /var/spool/postfix/pid
chmod -R 750 /var/spool/postfix/public
chmod -R 750 /var/spool/postfix/maildrop

chown -R postfix:postdrop /var/spool/postfix/maildrop
ls -ahl /var/spool/postfix/maildrop
chmod -R 750 /var/spool/postfix/pid

# Set permissions for vmaps file
chown postfix:postfix /etc/postfix/vmaps
chmod 644 /etc/postfix/vmaps

# Set permissions for /var/mail
chown -R vmail:vmail /var/mail
chmod -R 2770 /var/mail

# Start Postfix
/usr/sbin/postfix start-fg
