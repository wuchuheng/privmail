#!/bin/bash
# Import utils files.
DIR=$(dirname "$0")
. ${DIR}/../utility/utility.sh

# 1. If the user mail does not exist, create it.
user_exists_or_create postfix 1001

# 3. Start Dovecot.
dovecot -F
