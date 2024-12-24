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

# 4. Generate the aliases database.
cat /app/src/postfix/config/aliases > /etc/postfix/aliases 
postalias /etc/postfix/aliases
log INFO "Generated the aliases database."

# 5. Genreate the vmaps.db file if it doesn't exist.
vmaps_file="/etc/postfix/vmaps"
if [ ! -f "$vmaps_file.db" ]; then
    postmap "$vmaps_file"
    log INFO "Generated the vmaps.db file."
fi

# 6. Start Postfix
/usr/sbin/postfix start-fg -v