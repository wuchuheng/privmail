#!/bin/sh

# 1. Set the private keys belong root.
chown -R root:root /etc/opendkim/keys

# 2. If the private key file is not found, generate it.
file_path="/etc/opendkim/keys/mail.wuchuheng.com/default.private"
if [ ! -f $file_path ]; then
    # 2.1 If the directory is not found, create it.
    dir_path=$(dirname $file_path)
    if [ ! -d $dir_path ]; then
        mkdir -p $dir_path
    fi

    # 2.2 Generate the private key.
    opendkim-genkey -D $dir_path -d mail.wuchuheng.com -s default
    echo "Generated the private key. $file_path"
fi

# 3. Launch DKMI.
opendkim -f -k $file_path -p inet:8891@0.0.0.0