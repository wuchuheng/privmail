#!/bin/bash

# 1. Create vmail user and group.
# TODO: Make the user id and group id as environment variables in the docker-compose file.
groupadd -g ${VMAIL_GROUP_ID:-5000} vmail
useradd -u ${VMAIL_USER_ID:-5000} -g vmail -d /var/mail vmail

# 2. Set the directory permissions.
chown -R vmail:vmail /var/mail
chmod 2770 /var/mail

# 3. Set up the shared socket directory
mkdir -p /var/spool/postfix/private
chown postfix:postfix /var/spool/postfix/private
chmod 710 /var/spool/postfix/private

# 4. Start Dovecot.
dovecot -F
