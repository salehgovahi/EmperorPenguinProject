#!/bin/bash


# Author: Mohammad Saleh Govahi
# Created: September 17 2023
# Last Modified: September 18 2023
# Description: A script for connect to virtual machine with ssh.
# Usage: sudo bash SSHToVirtualMachine.sh OR sudo ./SSHToVirtualMachine.sh

# Variables
username="part"
vm_ip="192.168.97.131"
currentUser="karrar"
ssh_key="/home/$currentUser/.ssh/id_rsa"
password="secret123"

if [[ $EUID -eq 0 ]]; then

    echo "$ssh_key"
    sudo apt-get -y install openssh-server openssh-client >/dev/null 2>&1
    sudo apt-get -y install ssh >/dev/null 2>&1
    sudo apt-get -y install sshpass >/dev/null 2>&1
    sudo systemctl restart ssh

    sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$ssh_key" "$username@$vm_ip"

else
    echo "This script must be run as root."
    exit 1
fi