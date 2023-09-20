#!/bin/bash

# Author: Mohammad Saleh Govahi
# Created: September 17 2023
# Last Modified: September 18 2023
# Description: A script for first phase of PenguinEmperor project
# Usage: bash Bash.sh OR ./Bash.sh


function _deleteSubFolders() {
    echo "Preparing requirements ..."
    sudo rm -r Backup/ >/dev/null 2>&1
    sudo rm -r ConfigSettings/ >/dev/null 2>&1
}


function _downloadConfigSettings() {
    mkdir ConfigSettings
    cd ConfigSettings
    echo "Downloading Settings Files ..."
    wget --no-check-certificate https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/ConfigSettings/ConfigSettings/Sources.txt >/dev/null 2>&1 
    wget --no-check-certificate https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/ConfigSettings/ConfigSettings/NetworkConfig.txt >/dev/null 2>&1
    wget --no-check-certificate https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/ConfigSettings/ConfigSettings/NTPConfig.txt >/dev/null 2>&1
    cd ..
}


function _makeBackupFolder() {
    mkdir $(pwd)/Backup
}


function _backupFile() {
    sudo cp $1 $(pwd)/Backup
}


function _setRepository() {
    echo ""
    echo "Setting repository addresses ..."
    echo "After this operation, repository sources will be set to official repository addresses of Debian."

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        repo_file="$(pwd)/ConfigSettings/Sources.txt"
        if [[ -f $repo_file ]]; then
            # Write the repository sources file to /etc/apt/sources.list
            _backupFile /etc/apt/sources.list
            cat "$repo_file" | sudo tee /etc/apt/sources.list >/dev/null 2>&1
            sudo apt update >/dev/null 2>&1
            echo "Repository sources set successfully!"
        else
            echo "Sources.txt file not found. Please make sure it exists in the ConfigSettings directory. Maybe it didn't download."
        fi
    else
        echo "Skipping repository source setup ..."
    fi
}


function _configInterface() {
    echo ""
    echo "Configuring network ..."
    echo "After this operation, network will configure based on NetworkConfig.txt"

    read -p "Do you want to continue? [Y/n] " response

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        dns_file="$(pwd)/ConfigSettings/NetworkConfig.txt"
        if [[ -f $dns_file ]]; then
            _backupFile /etc/network/interfaces
            sudo cat "$dns_file" | sudo tee /etc/network/interfaces >/dev/null 2>&1
            systemctl restart networking
            echo "Network configuring done successfully!"
        else
            echo "NetworkConfig.txt file not found. Please make sure it exists in the ConfigSettings directory. Maybe it didn't download."
        fi
    else
        echo "Skipping networking setup..."
    fi
}


function _setNFT(){
    echo ""
    echo "Configuring network ..."
    echo "After this operation, network will configure based on NFTConfig.txt"

    read -p "Do you want to continue? [Y/n] " response

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        nft_file="$(pwd)/ConfigSettings/NTPConfig.txt"
        
        if [[ -f $nft_file ]]; then
            
            _backupFile /etc/systemd/timesyncd.conf
            cat "$nft_file" | sudo tee /etc/systemd/timesyncd.conf >/dev/null 2>&1
            sudo systemctl restart systemd-timesyncd.service 
            sudo timedatectl set-ntp true
            sudo timedatectl set-timezone Asia/Tehran
            sudo systemctl restart systemd-timesyncd.service

            echo "NTP configuring done successfully!"
        else
            echo "NTPConfig.txt file not found. Please make sure it exists in the ConfigSettings directory. Maybe it didn't download."
        fi
    else
        echo "Skipping NTP configuring setup..."
    fi
}

function _makeUser(){
    echo ""
    echo "Adding a user ..."
    echo "After this operation, a user with username:part and password:secret123 will make."
    echo "Expiration date of user is a month later and expiration date of paswword is a week later."

    read -p "Do you want to continue? [Y/n] " response

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        sudo useradd part -p secret123 -e $(date -d "+1 month" "+%Y-%m-%d")
        sudo sudo chage -E $(date -d "+7 days" "+%Y-%m-%d") part

        echo "Adding user done successfully!"
    else
        echo "Skipping adding user setup..."
    fi
}


function _changeRootPassword(){
    echo ""
    echo "Changing root user's password ..."
    echo "After this operation, root's password will be changed to Toor321"

    read -p "Do you want to continue? [Y/n] " response

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        echo "root:Toor321" | sudo chpasswd

        echo "Changing root's password done successfully!"
    else
        echo "Skipping changing root's password setup..."
    fi
}


function _installGit(){
    echo ""
    echo "Installing git from Debian repository ..."
    echo "After this operation, git package will install in your system."
    echo "Need to get 7,505 kB of archives."
    echo "38.2 MB of additional disk space will be used."
    
    read -p "Do you want to continue? [Y/n] " response

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        sudo apt-get -y install git >/dev/null

        echo "Installing git package was successfully!"
    else
        echo "Skipping installing git package setup..."
    fi
}


function _writeProccessScript(){
    echo ""
    echo "Write proccess showing script . . ."
    echo "After this operation, a script will be maked"
    echo "This script will show proccesses of user root that have PID less than 2000"
    
    read -p "Do you want to continue? [Y/n] " response

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        echo "ps -U root -o pid,command --no-headers | awk '$1<2000 {print $2}'" > ProccessScript.sh

        echo "Writing proccess script was successfully!"
    else
        echo "Skipping writing proccess script setup..."
    fi
}


function _configSSH(){
    echo ""
    echo "Install and configuring SSH service . . ."
    echo "After this operation, SSH will be installed and configued on your system."
    
    read -p "Do you want to continue? [Y/n] " response

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        sudo apt-get -y install openssh-server openssh-client >/dev/null
        sudo apt-get -y install ssh  >/dev/null
        echo "Openssh installed successfully!"
        echo "Configuring SSH . . ."

        sleep 1

        _backupFile /etc/ssh/sshd_config
        systemctl restart ssh

        echo "Installing and configuring SSH was successfully!"
    else
        echo "Skipping SSH installing and cofiguring setup..."
    fi
}


function _configNftable(){
    echo ""
    echo "Configuring firewall . . ."
    echo "After this operation, only port 22 will be accessible from outside of device."
    
    read -p "Do you want to continue? [Y/n] " response

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        echo "Configuring firewall . . ."
        
        sudo apt-get -y install nftables>/dev/null
        sudo apt-get -y upgrade nftables>/dev/null
        _backupFile /etc/nftables.conf
        sudo systemctl start nftables
        sudo nft add rule inet filter input tcp dport 22 accept
        sudo nft list ruleset > /etc/nftables.conf
        sudo nft -f /etc/nftables.conf
        sudo systemctl restart networking

        echo "Configuring firewall done successfully!"
    else
        echo "Skipping configuring firewall setup..."
    fi
}


# Check if the user is root
if [[ $EUID -eq 0 ]]; then
    _deleteSubFolders
    _downloadConfigSettings
    _makeBackupFolder
    _setRepository
    _configInterface
    _setNFT
    _makeUser
    _changeRootPassword
    _installGit
    _writeProccessScript
    _configSSH
    _configNftable
else
    echo "This script must be run as root."
    exit 1
fi