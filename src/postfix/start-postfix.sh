#!/bin/sh

# Import ../utility/utility.sh using a relative path
DIR="$(cd "$(dirname "$0")" && pwd)"
. "${DIR}/../utility/utility.sh"


# 1. Check the necessary environment variables
env_check MAIL_UID MAIL_GID MAIL_USER_NAME || exit 1

# 2. Check if the user exists or create it. 
user_exists_or_create ${MAIL_USER_NAME} ${MAIL_UID} || exit 1

# 3. Convert the template to the main.cf file
envsubst < ${DIR}/config/main.cf.template > /etc/postfix/main.cf

# 4. Start Postfix
/usr/sbin/postfix start-fg -v