#!/bin/bash
# Import utils files.
DIR=$(dirname "$0")
. ${DIR}/../utility/utility.sh

# 1. If the user mail does not exist, create it.
MAIL_UID=1001
user_exists_or_create vmail ${MAIL_UID}

# 2. Initialize the mail directory.
mail_dir=/var/mail/${DOMAIN}
if [ ! -d ${mail_dir} ]; then
    mkdir -p ${mail_dir}
fi

# 3. Initialze the test account.
test_account_dir=${mail_dir}/user
if [ ! -d ${test_account_dir} ]; then
    mkdir -p ${test_account_dir}
    chown -R ${MAIL_UID}:${MAIL_UID} ${mail_dir}
    chmod -R 700 ${mail_dir}
fi

# 4. Start Dovecot.
dovecot -F
