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
    echo "" >> ../error.logs
    echo "#-----------------------Downloading files--------------------------------#" >> ../error.logs
    echo "" >> ../error.logs
    wget --no-check-certificate https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/ConfigSettings/ConfigSettings/Sources.txt 2>> ../error.logs >/dev/null
    wget --no-check-certificate https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/ConfigSettings/ConfigSettings/NetworkConfig.txt 2>> ../error.logs >/dev/null
    wget --no-check-certificate https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/ConfigSettings/ConfigSettings/NTPConfig.txt 2>> ../error.logs >/dev/null
    cd ..
}


function _makeBackupFolder() {
    mkdir $(pwd)/Backup
}


function _backupFile() {
    sudo cp $1 $(pwd)/Backup
}

function _makeErrorLog(){
    sudo rm error.logs >/dev/null 2>&1 >/dev/null
    sudo touch error.logs
    echo "Error happend while running script :" > error.logs
}

function _makeLogTitle(){
    echo "" >> error.logs
    echo "#-----------------------$1--------------------------------#" >> error.logs
    echo "" >> error.logs
}


function _setRepository() {
    
    echo ""
    echo "Setting repository addresses ..."
    echo "After this operation, repository sources will be set to official repository addresses of Debian."
    _makeLogTitle "Setting repository :"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        repo_file="$(pwd)/ConfigSettings/Sources.txt"
        
        if [[ -f $repo_file ]]; then
            
            _backupFile /etc/apt/sources.list
            cat "$repo_file" | sudo tee /etc/apt/sources.list 2>> error.logs >/dev/null
            sudo apt update 2>> error.logs >/dev/null
            
            if [ $? -eq 0 ]; then
                echo "Repository addresses setting done successfully!"
            else
                echo "Failed to setting repository addresses. You can see in error.logs why setting failed."
            fi

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
    _makeLogTitle "Configuring Interface :"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        dns_file="$(pwd)/ConfigSettings/NetworkConfig.txt"
        
        if [[ -f $dns_file ]]; then
            
            _backupFile /etc/network/interfaces
            sudo cat "$dns_file" | sudo tee /etc/network/interfaces 2>> error.logs >/dev/null
            systemctl restart networking 2>> error.logs >/dev/null
            
            if [ $? -eq 0 ]; then
                echo "Network configuring done successfully!"
            else
                echo "Failed to configure Network. You can see in error.logs why configuring failed."
            fi

        else
            echo "NetworkConfig.txt file not found. Please make sure it exists in the ConfigSettings directory. Maybe it didn't download."
        fi
    
    else
        echo "Skipping networking setup..."
    fi
}


function _setNTP(){
    
    echo ""
    echo "Configuring NTP service ..."
    echo "After this operation, network will configure based on NTPConfig.txt"
    _makeLogTitle "Configuring NTP :"


    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        ntp_file="$(pwd)/ConfigSettings/NTPConfig.txt"
        
        if [[ -f $ntp_file ]]; then
            
            sudo apt install ntp 2>> error.logs >/dev/null
            _backupFile /etc/ntp.conf 2>> error.logs >/dev/null
            cat "$ntp_file" | sudo tee /etc/ntp.conf 2>> error.logs >/dev/null
            sudo systemctl restart ntp 2>> error.logs >/dev/null

            if [ $? -eq 0 ]; then
                echo "NTP configuring done successfully!"
            else
                echo "Failed to configure NTP. You can see in error.logs why configuring failed."
            fi

        else
            echo "NTPConfig.txt file not found. Please make sure it exists in the ConfigSettings directory. Maybe it didn't download."
        fi
    
    else
        echo "Skipping NTP configuring ..."
    fi
}

function _makeUser(){
    
    echo ""
    echo "Adding a user ..."
    echo "After this operation, a user with username:part and password:secret123 will make."
    echo "Expiration date of user is a month later and expiration date of paswword is a week later."
    _makeLogTitle "Making user :"


    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        sudo useradd part -p secret123 -e $(date -d "+1 month" "+%Y-%m-%d") 2>> error.logs >/dev/null
        sudo sudo chage -E $(date -d "+7 days" "+%Y-%m-%d") part 2>> error.logs >/dev/null

        if [ $? -eq 0 ]; then
            echo "User adding done successfully!"
        else
            echo "Failed to adding user. You can see in error.logs why adding failed."
        fi

    else
        echo "Skipping adding user ..."
    fi
}


function _changeRootPassword(){
    
    echo ""
    echo "Changing root user's password ..."
    echo "After this operation, root's password will be changed to Toor321"
    _makeLogTitle "Changing root's password :"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        echo "root:Toor321" | sudo chpasswd 2>> error.logs >/dev/null

        if [ $? -eq 0 ]; then
            echo "Root's password changing done successfully!"
        else
            echo "Failed to changing root's password. You can see in error.logs why changing failed."
        fi

    else
        echo "Skipping changing root's password ..."
    fi
}


function _installGit(){
    
    echo ""
    echo "Installing git from Debian repository ..."
    echo "After this operation, git package will install in your system."
    echo "Need to get 7,505 kB of archives."
    echo "38.2 MB of additional disk space will be used."
    _makeLogTitle "Installing Git :"
    
    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        sudo apt-get -y install git 2>> error.logs >/dev/null

        if [ $? -eq 0 ]; then
            echo "Git installing done successfully!"
        else
            echo "Failed to install Git. You can see in error.logs why installing failed."
        fi

    else
        echo "Skipping installing git package setup..."
    fi
}


function _writeProccessScript(){
    
    echo ""
    echo "Write proccess showing script . . ."
    echo "After this operation, a script will be maked"
    echo "This script will show proccesses of user root that have PID less than 2000"
    _makeLogTitle "Writing script :"
    
    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        echo "ps -U root -o pid,command --no-headers | awk '$1<2000 {print $2}'" > ProccessScript.sh

        if [ $? -eq 0 ]; then
            echo "Script writing done successfully!"
        else
            echo "Failed to writing script. You can see in error.logs why configuring failed."
        fi

    else
        echo "Skipping writing proccess script ..."
    fi
}


function _configSSH(){
    
    echo ""
    echo "Install and configuring SSH service . . ."
    echo "After this operation, SSH will be installed and configued on your system."
    _makeLogTitle "Configuring SSH :"
    
    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        sudo apt-get -y install openssh-server openssh-client 2>> error.logs >/dev/null
        sudo apt-get -y install ssh  2>> error.logs >/dev/null
        echo "Configuring SSH . . ."

        sleep 1

        _backupFile /etc/ssh/sshd_config
        systemctl restart ssh 2>> error.logs >/dev/null

        if [ $? -eq 0 ]; then
            echo "SSH configuring done successfully!"
        else
            echo "Failed to configuring SSH. You can see in error.logs why configuring failed."
        fi

    else
        echo "Skipping SSH installing and configuring ..."
    fi
}


function _configNftable(){
    
    echo ""
    echo "Configuring firewall . . ."
    echo "After this operation, only port 22 will be accessible from outside of device."
    _makeLogTitle "Configuring firewall :"
    
    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        echo "Configuring firewall . . ."
        
        sudo apt-get -y install nftables 2>> error.logs >/dev/null
        _backupFile /etc/nftables.conf
        sudo touch /etc/nftables.conf
        sudo systemctl start nftables 
        sudo nft add rule inet filter input tcp dport 22 accept 
        sudo nft list ruleset > /etc/nftables.conf 
        sudo nft -f /etc/nftables.conf 
        sudo systemctl restart networking 

        if [ $? -eq 0 ]; then
            echo "Firewall configuring done successfully!"
        else
            echo "Failed to configuring firewall. You can see in error.logs why configuring failed."
        fi

    else
        echo "Skipping configuring firewall ..."
    fi
}


# Check if the user is root
if [[ $EUID -eq 0 ]]; then

    ping -c 1 google.com >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        _makeErrorLog
        _deleteSubFolders
        _downloadConfigSettings
        _makeBackupFolder
        _setRepository
        _setNTP
        _makeUser
        _changeRootPassword
        _installGit
        _writeProccessScript
        _configSSH
        _configNftable
        _configInterface
    else
        echo "You should connect to the internet to run this script. Try again later."
    fi
else
    echo "This script must be run as root."
    exit 1
fi