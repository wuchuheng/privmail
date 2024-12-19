#!/bin/bash

# 1. Create the vmail group and user if they don't exist.
# TODO: Make the user id and group id as environment variables in the docker-compose file.
if ! getent group vmail > /dev/null; then   
    groupadd -g ${VMAIL_GROUP_ID:-5000} vmail
fi

if ! id -u vmail > /dev/null 2>&1; then
    useradd -u ${VMAIL_USER_ID:-5000} -g vmail -d /var/mail vmail
fi

# 2. Set the directory permissions.
chown -R vmail:vmail /var/mail
chmod 2770 /var/mail

# 3. Start Dovecot.
dovecot -F