#! /bin/bash

# Author: Mohammad Saleh Govahi
# Created: October 2 2023
# Last Modified: October 2 2023
# Description: A script for running phase 2 functions with http protocol
# Usage: bash Phase3RunScript.sh OR ./Phase3RunScript.sh

function _execute_command() {
    local command="$@"
    local log_file="$(pwd)/error.log"

    output=$(eval "$command" 2>&1)

    exit_status=$?
    if [[ $exit_status -ne 0 ]]; then
        echo "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] Command: $command" >> "$log_file" 2>/dev/null
        echo "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] Error: $output" >> "$log_file" 2>/dev/null
        return ${exit_status}
    else
        echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] Command: $command" >> "$log_file" 2>/dev/null
        echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] Output: $output" >> "$log_file" 2>/dev/null
        return ${exit_status}
    fi
}


function _makeBackupFolder() {
    mkdir $(pwd)/Backup
}

function _deleteErrorLog() {
    sudo rm error.log >/dev/null 2>&1
}


function _backupFile() {
    sudo cp $1 $(pwd)/Backup
}

function _makeErrorLog(){
    sudo rm error.log >/dev/null 2>&1
    sudo touch error.log
    echo "Error happend while running script :" > error.log
}

function _makeLogTitle(){
    echo "" >> error.log
    echo "#-----------------------$1--------------------------------#" >> error.log
    echo "" >> error.log
}


function _cloningImgProxy(){

    _makeLogTitle "Cloning imgproxy"
        
    if ! command -v git &> /dev/null; then

        _execute_command 'sudo apt-get -y install git'

        if ! [ $? -eq 0 ]; then
            exit 1
        fi

    fi

    _execute_command 'git clone https://github.com/imgproxy/imgproxy.git /opt/project'
    
    if ! [ $? -eq 0 ]; then
        exit 1
    fi
}

function _setLibvipsSources () {
	echo "deb http://deb.debian.org/debian bullseye main contrib non-free" >> /etc/apt/sources.list
 	echo "deb-src http://deb.debian.org/debian bullseye main contrib non-free" >> /etc/apt/sources.list
	echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list
    echo "deb-src http://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list
	echo "deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list
 	echo "deb-src http://deb.debian.org/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list
	sudo apt-get clean >/dev/null 2>&1
 	sudo apt-get update >/dev/null 2>&1
}

function _installLibVips(){

    _makeLogTitle "Install Libvips"
        
    _execute_command 'sudo apt-get -y install libvips-dev'
  
    if ! [ $? -eq 0 ]; then
        exit 1
    fi

}

function _installGolangCompiler(){

    _makeLogTitle "Install Golang"
        
    _execute_command 'sudo rm -rf /usr/local/go'
    _execute_command 'wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz'
    _execute_command 'sudo tar -xvf go1.21.0.linux-amd64.tar.gz'
    _execute_command 'sudo mv go /usr/local'

    if ! [ $? -eq 0 ]; then
        exit 1
    fi    
    
}

function _set403DNS () {
    sudo bash -c 'cat << EOF > /etc/resolv.conf
nameserver 10.202.10.202
nameserver 10.202.10.102
EOF'
}


function _runningImgProxy() {

    _makeLogTitle "Running imgproxy"
        
    cd /opt/project
	sudo CGO_LDFLAGS_ALLOW="-s|-w" /usr/local/go/bin/go build -buildvcs=false -o /usr/local/bin/imgproxy
        
    if ! [ -f /usr/local/bin/imgproxy ]; then
        exit 1
    fi

}

function _setDefaultDNS () {
    sudo bash -c 'cat << EOF > /etc/resolv.conf
nameserver 8.8.8.8
EOF'
}

function _setImgProxyUnitFile () {

    _makeLogTitle "Creating and setting imgproxy unit file"
        
    _execute_command 'wget --no-check-certificate https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/Phase1/ConfigSettings/imgproxyservice.txt'
    imgproxy_file="$(pwd)/imgproxyservice.txt"

    if [ -f $imgproxy_file ] ; then
            
        _execute_command 'sudo rm /etc/systemd/system/imgproxy.service'
        _execute_command 'sudo mv $imgproxy_file /etc/systemd/system/imgproxy.service'

            
        if [ -f /etc/systemd/system/imgproxy.service ] ; then
                
            _execute_command 'sudo systemctl daemon-reload'
            _execute_command 'sudo systemctl enable imgproxy.service'
            _execute_command 'sudo systemctl start imgproxy.service'


            if systemctl is-enabled imgproxy && systemctl is-active imgproxy; then
		echo "OK"
            else
                exit 1
            fi
                
        else
            exit 1  
        fi
    else
        exit 1 
    fi

}

function _checkHealthImgproxy () {
    
    _makeLogTitle "Imgproxy Healthcheck"

        
    url=http://localhost:8080/health
    x=$(curl -sI $url | grep HTTP | awk '{print $2}')
        
    if [ -z "$x" ]; then
        exit 1
    else
        if [ "$x" -eq 200 ]; then
            echo -e "$Imgproxy is running healthily."
        else
            exit 1
        fi
    fi
}

function _accessiblePort8080 () {

    _makeLogTitle "Configuring network"

    _execute_command 'sudo apt-get -y purge nftables'
    _execute_command 'sudo apt-get -y install nftables'
    _execute_command 'sudo systemctl enable nftables'
    _execute_command 'sudo systemctl start nftables'
    _execute_command 'sudo nft add rule inet filter input tcp dport 8080 accept'
    _execute_command 'sudo nft list ruleset > /etc/nftables.conf'
    _execute_command 'sudo nft -f /etc/nftables.conf'
    _execute_command 'sudo systemctl restart nftables'
        
    if ! [ $? -eq 0 ]; then
        exit 1
    fi  

}

# function _rollbackAllConfigurationsSIGINT() {

#     clear
#     _makeLogTitle "Rollback All Configurations ..."

#     _execute_command 'sudo rm -r /opt/project'

#     _execute_command 'sudo apt-get -y purge libvips-dev'

#     _execute_command 'sudo apt-get -y purge golang'
        
#     _execute_command 'sudo apt-get -y autoremove'

#     _execute_command 'sudo rm /usr/local/bin/imgproxy'

#     _execute_command 'sudo rm /etc/systemd/system/imgproxy.service'
        
#     _execute_command 'sudo systemctl stop imgproxy.service'
        
#     _execute_command 'sudo systemctl daemon-reload'

#     _execute_command 'sudo systemctl restart nftables'
        
#     _execute_command 'sudo nft delete rule inet filter input handle 4'
        
#     _execute_command 'sudo nft list ruleset > /etc/nftables.conf'
        
#     _execute_command 'sudo nft -f /etc/nftables.conf'

#     exit 1

# }

if [[ $EUID -eq 0 ]]; then

    ping -c 1 8.8.8.8 >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
    _deleteErrorLog
    _cloningImgProxy
	_setLibvipsSources
    _installLibVips
    _set403DNS
    _installGolangCompiler
    _runningImgProxy
    _setDefaultDNS
    _setImgProxyUnitFile
    _checkHealthImgproxy
    _accessiblePort8080         
    else
        echo "You should connect to the internet to run this script. Try again later."
    fi
else
    echo "This script must be run as root."
    exit 1
fi
