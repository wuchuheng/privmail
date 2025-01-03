#!/bin/bash
set -euo pipefail

# Import ../utility/utility.sh using a relative path
DIR="$(cd "$(dirname "$0")" && pwd)"
. "${DIR}/../utility/utility.sh"

# Generate Private Key
generate_private_key() {
    local domain dir_path file_path
    domain="$1"
    file_path="$2"
    dir_path=$(dirname "$file_path")

    mkdir -p "$dir_path"
    opendkim-genkey -D "$dir_path" -d "$domain" -s default
    chmod 600 "$file_path"
    log "INFO" "Generated the private key at $file_path with restricted permissions."
}

# Generate OpenDKIM configuration
generate_config() {
    # 1. Init the input arguments.
    local domain temp_config
    domain="$1"
    private_key_file="$2"


    # 2. Create a tempfile. the formate like: /tmp/opendkim_temp.$timestamp.conf
    timestamp=$(date +%s)
    temp_config=/tmp/opendkim_temp.$timestamp.conf

    # 3. Write the configuration to the tempfile.
    cat <<EOF > "$temp_config"
Domain                 $domain
KeyFile                $private_key_file
Selector               default
Socket                 inet:8891@0.0.0.0
RequireSafeKeys        false
Syslog                 yes
UMask                  002
EOF

    # 4. Return the tempfile.
    echo "$temp_config"
}

# Main execution
main() {
    log "INFO" "Starting OpenDKIM setup for domain ${MAIL_DOMAIN}."

    # 1. Generate the private key.
    PRIVATE_KEY_FILE="/etc/opendkim/keys/${MAIL_DOMAIN}/default.private"
    if [ ! -f "$PRIVATE_KEY_FILE" ]; then
        generate_private_key "$MAIL_DOMAIN" "$PRIVATE_KEY_FILE"
    else
        log "INFO" "Private key already exists at $PRIVATE_KEY_FILE."
    fi

    # 2. Generate the temporary configuration file.
    TEMP_CONFIG=$(generate_config "$MAIL_DOMAIN" "$PRIVATE_KEY_FILE")
    trap 'rm -f "$TEMP_CONFIG"' EXIT

    # 3. Start OpenDKIM.
    opendkim -f -x "$TEMP_CONFIG" -v
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to start OpenDKIM."
        exit 2
    fi
}

# Start the main execution.
main "$@"