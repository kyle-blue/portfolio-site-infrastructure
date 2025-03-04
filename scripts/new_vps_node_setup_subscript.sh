#!/bin/sh

# In most cases you will want to run this in docker
# Use the new_vps_node_setup_docker.sh script

apt update
apt install -y ssh rsync

DIR=$(dirname "$(readlink -f "$0")")

printf "Enter node ip: "
read IP

USER_NAME="cluster-admin"
NEW_SSH_PORT="44444"

RANDOM_STRING=$(tr -dc a-z </dev/urandom | head -c 5 ; echo '')
SSH_FILE_NAME="ed25519_cluster_node_${RANDOM_STRING}"
SSH_DIR=$(readlink -e ~/.ssh)
ssh-keygen -t ed25519 -f "$SSH_DIR/$SSH_FILE_NAME"

chown $USER ~/.ssh/config
chmod 644 ~/.ssh/config

# Remove from known hosts
ssh-keygen -f "$SSH_DIR/known_hosts" -R "$IP"
ssh-keygen -f "$SSH_DIR/known_hosts" -R "$IP" 2> /dev/null

ssh -o StrictHostKeyChecking=accept-new root@$IP "apt install -y rsync"
rsync "$SSH_DIR/$SSH_FILE_NAME.pub" root@$IP:/tmp
rsync "$DIR/sshd_config" root@$IP:/tmp

PUBLIC_IP=$(curl -s https://icanhazip.com)

SSH_COMMAND=$(cat <<EOF
apt update
apt install -y vim sudo ufw git rsync
echo
echo "ENTER NEW PASSWORD FOR USER"
echo
adduser $USER_NAME
usermod -aG sudo $USER_NAME
echo
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 6443/tcp
ufw allow $NEW_SSH_PORT/tcp
ufw allow from $PUBLIC_IP to any port 30003
echo
mkdir -p /home/$USER_NAME/.ssh
cat /tmp/$SSH_FILE_NAME.pub > /home/$USER_NAME/.ssh/authorized_keys
cat /tmp/sshd_config > /etc/ssh/sshd_config
chown $USER_NAME:$USER_NAME -R /home/$USER_NAME
systemctl reload ssh
#do this: ufw enable
EOF
)

# Replaces newlines with &&
echo "$SSH_COMMAND"
SSH_COMMAND=$(echo "$SSH_COMMAND" | sed ':a;N;$!ba;s/\n/ \&\& /g')

ssh -o StrictHostKeyChecking=accept-new root@$IP $SSH_COMMAND

HOST_INFO=$(cat <<EOF

Host cluster-node-$RANDOM_STRING
    HostName $IP
    user $USER_NAME
    port $NEW_SSH_PORT
    IdentityFile ~/.ssh/$SSH_FILE_NAME

EOF
)

echo "$HOST_INFO" >> ~/.ssh/config

echo "\nDone!"
echo "ssh into new account with:"
echo "ssh cluster-node-$RANDOM_STRING"
