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

# 5. Generate the vmaps.db file if it doesn't exist.
vmaps_file="/etc/postfix/vmaps"
vmaps_db_file="${vmaps_file}.lmdb"
if [ ! -f "$vmaps_db_file" ]; then
    # Ensure proper permissions on the directory
    chown root:root -R /etc/postfix
    chmod 755 /etc/postfix
    
    # Generate the database as postfix user
    postmap $vmaps_file
    if [ $? -eq 0 ]; then
        log INFO "Generated the vmaps.lmdb file."
        # Make the permissions as root:root to avoid the permission warning from Postfix when starting.
    else
        log ERROR "Failed to generate the vmaps.lmdb file."
    fi
fi

# 6. Set the permissions of the private folder.
chown postfix:postfix -R /var/spool/postfix/private

# 6. Start Postfix
/usr/sbin/postfix start-fg -v
