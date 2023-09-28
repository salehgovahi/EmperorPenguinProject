#!/bin/bash

# Author: Mohammad Saleh Govahi
# Created: September 17 2023
# Last Modified: September 18 2023
# Description: A script for first phase of PenguinEmperor project
# Usage: bash Bash.sh OR ./Bash.sh

red='\033[0;31m'

green='\033[0;32m'

trap '_rollbackAllConfigurationsSIGINT' INT

function _backToDefaultColor (){
    tput sgr0
}

function _deleteSubFolders() {
    echo "Preparing requirements ..."
    sudo rm -r Backup/ >/dev/null 2>&1 
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
    _makeLogTitle "Setting repository"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        repo_file="$(pwd)/ConfigSettings/Sources.txt"
        
        if [[ -f $repo_file ]]; then
            
            _backupFile /etc/apt/sources.list
            cat "$repo_file" | sudo tee /etc/apt/sources.list 2>> error.logs >/dev/null
            sudo apt update 2>> error.logs >/dev/null
            
            if [ $? -eq 0 ]; then
                echo -e "${green}Setting repository done successfully"
                _backToDefaultColor
            else
                echo -e "${red}Failed to setting repository. You can see in error.logs why setting failed."
                _backToDefaultColor
                _rollBackSettingRepository
            fi

        else
            echo -e "${red}Sources.txt file not found. Please make sure it exists in the ConfigSettings directory. Maybe it didn't download."
            _backToDefaultColor
        fi
    
    else
        echo "Skipping repository source setup ..."
    fi
}

function _rollBackSettingRepository () {
    
    echo ""
    echo "Roll back setting repository ..."
    echo "After this operation, your repository sources will be roll back to a version before."
    _makeLogTitle "Rollback setting repository"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        repo_backup="$(pwd)/Backup/sources.list"
        cat "$repo_backup" | sudo tee /etc/apt/sources.list 2>> error.logs >/dev/null
        sudo apt update 2>> error.logs >/dev/null
                
        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback setting repository done successfully"
            _backToDefaultColor
            _setRepository
        else
            echo -e "${red}Failed to rollback setting repository. You can see in error.logs why rollback failed."
            _backToDefaultColor
            exit 1
        fi
    
    else
        echo "Skipping from setting repository rollback . . . "
    fi 
}


function _configInterface() {
    
    echo ""
    echo "Configuring network ..."
    echo "After this operation, network will configure based on NetworkConfig.txt"
    _makeLogTitle "Configuring network"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        dns_file="$(pwd)/ConfigSettings/NetworkConfig.txt"
        
        if [[ -f $dns_file ]]; then
            
            _backupFile /etc/network/interfaces
            sudo cat "$dns_file" | sudo tee /etc/network/interfaces 2>> error.logs >/dev/null
            systemctl restart networking 2>> error.logs >/dev/null
            systemctl restart NetworkManager 2>> error.logs >/dev/null
            
            if [ $? -eq 0 ]; then
                echo -e "${green}Configuring network done successfully"
                _backToDefaultColor
            else
                echo -e "${red}Failed to configuring network. You can see in error.logs why configuring failed."
                _backToDefaultColor
                _rollBackConfiguringInterface
            fi

        else
            echo -e "${red}NetworkConfig.txt file not found. Please make sure it exists in the ConfigSettings directory. Maybe it didn't download."
            _backToDefaultColor
        fi
    
    else
        echo "Skipping from network configuring ..."
    fi
}

function _rollBackConfiguringInterface () {
    
    echo ""
    echo "Roll back configuring interface ..."
    echo "After this operation, your interfaces configuration will be roll back to a version before."
    _makeLogTitle "Rollback configuring interface"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        interface_backup="$(pwd)/Backup/interfaces"
        sudo cat "$interface_backup" | sudo tee /etc/network/interfaces 2>> error.logs >/dev/null
        systemctl restart networking 2>> error.logs >/dev/null
        systemctl restart NetworkManager 2>> error.logs >/dev/null
                
        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback network configuring done successfully"
            _backToDefaultColor
            _configInterface
        else
            echo -e "${red}Failed to rollback configuring network. You can see in error.logs why rollback failed."
            _backToDefaultColor
            exit 1
        fi
    
    else
        echo "Skipping from network configuring rollback . . . "
    fi 
}


function _setNTP(){
    
    echo ""
    echo "Setting NTP server ..."
    echo "After this operation, NTP server will be set based on NTPConfig.txt"
    _makeLogTitle "Setting NTP server"


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
                echo -e "${green}Setting NTP server done successfully"
                _backToDefaultColor
            else
                echo -e "${red}Failed to setting NTP server. You can see in error.logs why setting failed."
                _backToDefaultColor
                _rollBackSettingNTP
            fi

        else
            echo "NTPConfig.txt file not found. Please make sure it exists in the ConfigSettings directory. Maybe it didn't download."
        fi
    
    else
        echo "Skipping from setting NTP server ..."
    fi
}

function _rollBackSettingNTP () {
    
    echo ""
    echo "Roll back setting NTP ..."
    echo "After this operation, your NTP server will be roll back to a version before."
    _makeLogTitle "Rollback setting NTP server"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        NTP_backup="$(pwd)/Backup/ntp.conf"
        sudo cat "$NTP_backup" | sudo tee /etc/ntp.conf 2>> error.logs >/dev/null
        sudo systemctl restart ntp 2>> error.logs >/dev/null
                
        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback setting NTP server done successfully"
            _backToDefaultColor
            _setNTP
        else
            echo -e "${red}Failed to rollback setting NTP server. You can see in error.logs why rollback failed."
            _backToDefaultColor
            exit 1
        fi
    
    else
        echo "Skipping from setting NTP server rollback . . . "
    fi 
}

function _makeUser(){
    
    echo ""
    echo "Adding a user ..."
    echo "After this operation, a user with username:part and password:secret123 will be added."
    echo "Expiration date of user is a month later and expiration date of paswword is a week later."
    _makeLogTitle "Adding user"


    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        sudo useradd part -p secret123 -e $(date -d "+1 month" "+%Y-%m-%d") 2>> error.logs >/dev/null
        sudo sudo chage -E $(date -d "+7 days" "+%Y-%m-%d") part 2>> error.logs >/dev/null
        sudo usermod -aG sudo part

        if [ $? -eq 0 ]; then
            echo -e "${green}Adding user done successfully"
            _backToDefaultColor
        else
            echo -e "${red}Failed to adding user. You can see in error.logs why adding failed."
            _backToDefaultColor
            _rollBackMakingUser
        fi

    else
        echo "Skipping from adding user ..."
    fi
}

function _rollBackMakingUser () {
    
    echo ""
    echo "Rollback adding user..."
    echo "After this operation, user that you made will be removed from your device."
    _makeLogTitle "Rollback adding user"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        sudo userdel -r part 2>> error.logs >/dev/null
                
        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback adding user done successfully"
            _backToDefaultColor
            _makeUser
        else
            echo -e "${red}Failed to rollback adding user. You can see in error.logs why rollback failed."
            _backToDefaultColor
            exit 1
        fi
    
    else
        echo "Skipping from making user rollback . . . "
    fi 
}

function _changeRootPassword(){
    
    echo ""
    echo "Changing password of root user ..."
    echo "After this operation, root's password will be changed to Toor321"
    _makeLogTitle "Changing root's password"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then

        echo "root:Toor321" | sudo chpasswd

        if [ $? -eq 0 ]; then
            echo -e "${green}Changing password of root user done successfully!"
            _backToDefaultColor
        else
            echo -e "${red}Failed to changing password of root. You can see in error.logs why changing failed."
            _backToDefaultColor
        fi

    else
        echo "Skipping changing root's password ..."
    fi
}


function _writeProccessScript(){
    
    echo ""
    echo "Write proccess showing script . . ."
    echo "After this operation, a script will be writed."
    echo "This script will show proccesses of user root that have PID less than 2000"
    _makeLogTitle "Writing script"
    
    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        local param1='$1'
        local param2='$2'
        echo "ps -U root -o pid,command --no-headers | awk '$param1<2000 {print $param2}'" > ProccessScript.sh

        if [ $? -eq 0 ]; then
            echo -e "${green}Script writing done successfully!"
            _backToDefaultColor
        else
            echo -e "${red}Failed to writing script. You can see in error.logs why writing failed."
            _backToDefaultColor
            _rollBackWritingProcessScript
        fi

    else
        echo "Skipping from proccess script writing  ..."
    fi
}

function _rollBackWritingProcessScript () {

    echo ""
    echo "Rollback proccess script writing ..."
    echo "After this operation, process script will be removed from your device."
    _makeLogTitle "Rollback writing script"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then

        sudo rm ProccessScript.sh

        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback script writing  done successfully!"
            _backToDefaultColor
            _writeProccessScript
        else
            echo -e "${red}Failed to rollback script writing. You can see in error.logs why rollback failed."
            _backToDefaultColor
            exit 1
        fi

    else
        echo "Skipping writing script rollback ..."
    fi

}


function _configSSH(){
    
    echo ""
    echo "Install and configuring SSH service . . ."
    echo "After this operation, SSH will be installed and configued on your system."
    _makeLogTitle "Installing & configuring SSH"
    
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
            echo -e "${green}SSH configuring done successfully!"
            _backToDefaultColor
        else
            echo -e "${red}Failed to configuring SSH. You can see in error.logs why configuring failed."
            _backToDefaultColor
            _rollBackConfiguringSSH
        fi

    else
        echo "Skipping from installing & configuring SSH ..."
    fi
}


function _rollBackConfiguringSSH () {

    echo ""
    echo "Rollback installing & configuring SSH ..."
    echo "After this operation, SSH will be removed from your device."
    _makeLogTitle "Rollback configuring SSH"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then

        sudo apt-get -y purge openssh-server openssh-client 2>> error.logs >/dev/null
        sudo apt-get -y purge ssh 2>> error.logs >/dev/null

        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback configuring SSH done successfully!"
            _backToDefaultColor
            _configSSH
        else
            echo -e "${red}Failed to rollback configuring SSH. You can see in error.logs why rollback failed."
            _backToDefaultColor
            exit 1
        fi

    else
        echo "Skipping configuring SSH rollback ..."
    fi

}


function _configNftable(){
    
    echo ""
    echo "Configuring firewall . . ."
    echo "After this operation, only port 22 will be accessible from outside of device."
    _makeLogTitle "Configuring firewall"
    
    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        echo "Configuring firewall . . ."

        _backupFile /etc/nftables.conf

        sudo apt purge nftables 2>> error.logs >/dev/null

        sudo apt install nftables 2>> error.logs >/dev/null
        sudo systemctl start nftables 2>> error.logs >/dev/null
        sudo systemctl enable nftables 2>> error.logs >/dev/null
        sudo systemctl start nftables 2>> error.logs >/dev/null
        sudo systemctl restart nftables 2>> error.logs >/dev/null
        sudo nft add rule inet filter input tcp dport 22 accept
        sudo nft list ruleset > /etc/nftables.conf
        sudo nft -f /etc/nftables.conf
        sudo systemctl restart nftables 2>> error.logs >/dev/null
        sudo systemctl stop nftables
        sudo systemctl disable nftables
        sudo systemctl enable nftables
        sudo systemctl start nftables
        sudo systemctl restart nftables 2>> error.logs >/dev/null
        
        
        if [ $? -eq 0 ]; then
            echo -e "${green}Firewall configuring done successfully!"
            _backToDefaultColor
        else
            echo -e "${red}Failed to configuring firewall. You can see in error.logs why configuring failed."
            _backToDefaultColor
            _rollBackConfiguringNftable
        fi

    else
        echo "Skipping configuring firewall ..."
    fi
}


function _rollBackConfiguringNftable () {

    echo ""
    echo "Rollback configuring firewall ..."
    echo "After this operation, rule dport 22 will be removed from your firewall."
    _makeLogTitle "Rollback firewall configuring"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,}

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then

        sudo systemctl restart nftables
        sudo sudo nft delete rule inet filter input handle 4
        sudo nft list ruleset > /etc/nftables.conf
        sudo nft -f /etc/nftables.conf
        sudo systemctl restart nftables

        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback firewall configuring done successfully!"
            _backToDefaultColor
            _configNftable
        else
            echo -e "${red}Failed to rollback firewall configuring. You can see in error.logs why rollback failed."
            _backToDefaultColor
            exit 1
        fi

    else
        echo "Skipping from firewall configuring rollback ..."
    fi

}

function _rollbackAllConfigurations () {
    
    echo ""
    echo "Rolling back all configurations..."
    echo "After this operation, all configurations will be rolled back."
    _makeLogTitle "Rollback All Configurations"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        repo_backup="$(pwd)/Backup/sources.list"
        if [[ -f $repo_backup ]]; then
            cat "$repo_backup" | sudo tee /etc/apt/sources.list 2>> error.logs >/dev/null
            sudo apt update 2>> error.logs >/dev/null

            interface_backup="$(pwd)/Backup/interfaces"
            sudo cat "$interface_backup" | sudo tee /etc/network/interfaces 2>> error.logs >/dev/null
            systemctl restart networking 2>> error.logs >/dev/null
            systemctl restart NetworkManager 2>> error.logs >/dev/null

            NTP_backup="$(pwd)/Backup/ntp.conf"
            sudo cat "$NTP_backup" | sudo tee /etc/ntp.conf 2>> error.logs >/dev/null
            sudo systemctl restart ntp 2>> error.logs >/dev/null

            sudo userdel -r part 2>> error.logs >/dev/null

            sudo rm ProccessScript.sh 2>> error.logs >/dev/null

            sudo apt-get -y purge openssh-server openssh-client 2>> error.logs >/dev/null
            sudo apt-get -y purge ssh 2>> error.logs >/dev/null

            sudo systemctl restart nftables
            sudo sudo nft delete rule inet filter input handle 4
            sudo nft list ruleset > /etc/nftables.conf
            sudo nft -f /etc/nftables.conf
            sudo systemctl restart nftables

            echo -e "${green}Rollback all configurations done successfully."

        else 
            echo "It seems you did not any configuration"
        fi

        
        _backToDefaultColor
        sleep 3

    else
        echo "Skipping rollback all configurations..."
    fi

}

function _rollbackAllConfigurationsSIGINT () {
    
    clear
    echo "You sent interrupt signal to proccess"
    echo "Rolling back all configurations..."
    _makeLogTitle "Rollback All Configurations SIGINT"
        
        repo_backup="$(pwd)/Backup/sources.list"
        if [[ -f $repo_backup ]]; then
            cat "$repo_backup" | sudo tee /etc/apt/sources.list 2>> error.logs >/dev/null
            sudo apt update 2>> error.logs >/dev/null

            interface_backup="$(pwd)/Backup/interfaces"
            if [[ -f $interface_backup ]]; then
                sudo cat "$interface_backup" | sudo tee /etc/network/interfaces 2>> error.logs >/dev/null
                systemctl restart networking 2>> error.logs >/dev/null
                systemctl restart NetworkManager 2>> error.logs >/dev/null
            fi

            if [[ -f $interface_backup ]]; then
                NTP_backup="$(pwd)/Backup/ntp.conf"
                sudo cat "$NTP_backup" | sudo tee /etc/ntp.conf 2>> error.logs >/dev/null
                sudo systemctl restart ntp 2>> error.logs >/dev/null
            fi

            sudo userdel -r part 2>> error.logs >/dev/null

            sudo rm ProccessScript.sh 2>> error.logs >/dev/null

            sudo apt-get -y purge openssh-server openssh-client 2>> error.logs >/dev/null
            sudo apt-get -y purge ssh 2>> error.logs >/dev/null

            sudo systemctl restart nftables
            sudo sudo nft delete rule inet filter input handle 4
            sudo nft list ruleset > /etc/nftables.conf
            sudo nft -f /etc/nftables.conf
            sudo systemctl restart nftables

            echo -e "${green}Rollback all configurations done successfully."

        else 
            echo "It seems you did not any configuration"
        fi

        _backToDefaultColor
        sleep 1

    exit 1

}


. "bash-menu.sh"

actionA() {
    echo "Running Script ..."
    _makeErrorLog
    _deleteSubFolders
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
    sleep 10
    return 1
}

actionB() {
    echo "Roll Back all configurations ..."
    _rollbackAllConfigurations
    return 1
}

actionC() {
    sudo xdg-open https://stackoverflow.com


    return 1
}


actionX() {
    return 0
}


menuItems=(
    "1. Running Script"
    "2. RollBack All Configurations"
    "3. About Script"
    "4. Exit  "
)

## Menu Item Actions
menuActions=(
    actionA
    actionB
    actionC
    actionX
)


menuTitle=" Demo of bash-menu"
menuFooter=" Enter=Select, Navigate via Up/Down/First number/letter"
menuWidth=60
menuLeft=25
menuHighlight=$DRAW_COL_YELLOW


if [[ $EUID -eq 0 ]]; then

    ping -c 1 8.8.8.8 >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        menuInit
        menuLoop          
    else
        echo "You should connect to the internet to run this script. Try again later."
    fi
else
    echo "This script must be run as root."
    exit 1
fi
