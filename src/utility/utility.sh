#!/bin/bash

##
# Logging function with timestamp and level
# @Usage: log "INFO" "This is an info message"
# Level: INFO, ERROR, WARNING
##
log() {
    local level message
    
    #1. Style the log level
    level="$1"
    case "$level" in
        "INFO") level="\033[1;32mINFO\033[0m" ;;
        "ERROR") level="\033[1;31mERROR\033[0m" ;;
        "WARNING") level="\033[1;33mWARNING\033[0m" ;;
        *) level="\033[1;37mUNKNOWN\033[0m" ;;
    esac
    
    shift
    message="$@"
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message"
}

##
# Check if the environment variables are set or not
# @Usage: env_check ENV1 ENV2 ENV3 ...
##
env_check() {
    local env_var
    for env_var in "$@"; do
        eval "value=\$$env_var"
        if [ -z "$value" ]; then
            log "ERROR" "Environment variable $env_var is not set"
            return 1
        fi
    done

    return 0
}

##
# Check if the user exists or create it.
# @Usage: user_exists_or_create USER_NAME USER_ID
##
user_exists_or_create() {
    local user_name user_id
    user_name="$1"
    user_id="$2"
    if ! id "$user_name" &>/dev/null; then
        useradd -u "$user_id" "$user_name"
        log "INFO" "User $user_name created with id $user_id"
    fi
}

