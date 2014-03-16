#!/bin/bash

# The mapped volume that lives outside this container, where persistent data is to be stored
DATA_DIR=/var/lib/gitlab

# The mapped volume is mandatory; there isn't any point letting the user continue without it
if [ ! -d "$DATA_DIR" ]; then
  echo -e "\e[1;31mFatal error: You have not mapped a volume to $DATA_DIR. Please do so when starting this container.\e[0m"
  exit 1
fi

cd $DATA_DIR

# Create directories and files if they do not exist
mkdir -p repositories
mkdir -p gitlab-satellites
mkdir -p ssh-host-keys
touch authorized_keys

# Set ownership and permissions
chown -R git:git *
chmod -R ug+rwX,o-rwx *

# Link authorized_keys to expected location and set correct permissions
ln -sf $DATA_DIR/authorized_keys /home/git/.ssh/authorized_keys
chmod 0700 /home/git/.ssh/authorized_keys

# Link SSH host keys to expected location and set correct permissions
if [[ ! -e $DATA_DIR/ssh-host-keys/ssh_host_rsa_key ]]; then
  echo "No SSH host key available. Generating one..."
  export LC_ALL=C
  export DEBIAN_FRONTEND=noninteractive
  dpkg-reconfigure openssh-server
  cp /etc/ssh/ssh_host_*_key $DATA_DIR/ssh-host-keys/
  cp /etc/ssh/ssh_host_*_key.pub $DATA_DIR/ssh-host-keys/
fi
ln -sf $DATA_DIR/ssh-host-keys/* /etc/ssh/
