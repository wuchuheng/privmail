#!/bin/bash
set -euo pipefail

# Logging function with timestamp and level
log() {
    local level message
    level="$1"
    shift
    message="$@"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message"
}

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
    log "INFO" "Starting OpenDKIM setup for domain $DOMAIN."

    # 1. Generate the private key.
    PRIVATE_KEY_FILE="/etc/opendkim/keys/$DOMAIN/default.private"
    if [ ! -f "$PRIVATE_KEY_FILE" ]; then
        generate_private_key "$DOMAIN" "$PRIVATE_KEY_FILE"
    else
        log "INFO" "Private key already exists at $PRIVATE_KEY_FILE."
    fi

    # 2. Generate the temporary configuration file.
    TEMP_CONFIG=$(generate_config "$DOMAIN" "$PRIVATE_KEY_FILE")
    trap 'rm -f "$TEMP_CONFIG"' EXIT

    echo "tmpenv: $DOMAIN"
    # 3. Start OpenDKIM.
    opendkim -f -x "$TEMP_CONFIG" -v
    if [ $? -ne 0 ]; then
        log "ERROR" "Failed to start OpenDKIM."
        exit 2
    fi
}

# Start the main execution.
main "$@"