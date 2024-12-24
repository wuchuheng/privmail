#!/bin/sh

# Import ../utility/utility.sh using a relative path
DIR="$(cd "$(dirname "$0")" && pwd)"
. "${DIR}/../utility/utility.sh"


# 1. Check the necessary environment variables
env_check MAIL_UID MAIL_GID MAIL_USER_NAME MAIL_DOMAIN || exit 1

# 2. Check if the user exists or create it. 
user_exists_or_create ${MAIL_USER_NAME} ${MAIL_UID} || exit 1

# 3. Convert the template to the main.cf file
envsubst '${MAIL_DOMAIN} ${MAIL_USER_NAME}' < ${DIR}/config/main.cf.template > /etc/postfix/main.cf

# 4. Set correct permissions for Postfix directories
postfix_dirs="/var/spool/postfix /var/lib/postfix"
for dir in $postfix_dirs; do
    chown -R ${MAIL_USER_NAME}:${MAIL_USER_NAME} $dir
    chmod -R 0700 $dir
done


# Enable verbose logging and switch to foreground mode
log INFO "=== Postfix Configuration Check ==="
postconf -n
/usr/sbin/postfix start-fg -v
