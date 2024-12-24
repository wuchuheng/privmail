#!/bin/sh

# Import ../utility/utility.sh using a relative path
DIR="$(cd "$(dirname "$0")" && pwd)"
. "${DIR}/../utility/utility.sh"


# 1. Check the necessary environment variables
env_check MAIL_UID MAIL_DOMAIN || exit 1

# 2. Check if the user exists or create it. 
user_exists_or_create postfix ${MAIL_UID} || exit 1

# 3. Convert the template to the main.cf file
envsubst '${MAIL_DOMAIN}' < ${DIR}/config/main.cf.template > /etc/postfix/main.cf

# 5. Start Postfix
/usr/sbin/postfix start-fg -v
