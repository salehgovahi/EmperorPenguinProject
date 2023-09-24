#! /bin/bash

# Author: Mohammad Saleh Govahi
# Created: September 23 2023
# Last Modified: September 23 2023
# Description: A script for setting up imgproxy (second phase of PenguinEmperor project)
# Usage: bash Bash(Setting up imgproxy).sh OR ./Bash(Setting up imgproxy).sh

red='\033[0;31m'

green='\033[0;32m'


function _makeBackupFolder() {
    mkdir $(pwd)/Backup
}

function _deleteErrorLog() {
    sudo rm error.logs
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

function _backToDefaultColor (){
    tput sgr0
}


function _cloningImgProxy(){

    echo ""
    echo "Cloning imgproxy ..."
    echo "After this operation, imgproxy code will be cloned from its repository in github to /opt/project/ ."
    _makeLogTitle "Cloning imgproxy"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        if ! command -v git &> /dev/null; then
            echo "Git is not installed on your system. To continue running this script, you should install Git on your system."
            read -p "Do you want to install it? [Y/n] " response
            response=${response,,}

            # If the user wants to install git, install it
            if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
                sudo apt-get -y install git 2>> error.logs >/dev/null

                # Check if git was successfully installed
                if [ $? -eq 0 ]; then
                    echo -e "${green}Git installing done successfully!"
                    _backToDefaultColor
                else
                    echo -e "${red}Failed to install Git. You can see in error.logs why installing failed."
                    _backToDefaultColor
                    exit 1
                fi
            fi
        fi

        git clone https://github.com/imgproxy/imgproxy.git /opt/project 2>> error.logs

        
        if [ $? -eq 0 ]; then
            echo -e "${green}Cloning imgproxy to /opt/project done successfully"
            _backToDefaultColor
        else
            echo -e "${red}Failed to cloning from Git. You can see in error.logs why cloning failed."
            _backToDefaultColor
            _rollBackCloningImgProxy
        fi
    
    else
        echo "Skipping from this step is not allowed."
        echo "You should have imgproxy to continue running script."
        exit 1
    fi
}

function _rollBackCloningImgProxy(){
    echo ""
    echo "Roll back cloning imgproxy ..."
    echo "After this operation, imgproxy code will be removed from its directory in your system."
    _makeLogTitle "Rollback cloning imgproxy"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        sudo rm -r /opt/project 2>> error.logs

        
        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback cloning imgproxy to done successfully"
            _backToDefaultColor
            _cloningImgProxy
        else
            echo -e "${red}Failed to rollback cloning imgproxy. You can see in error.logs why rollback failed."
            _backToDefaultColor
            exit 1
        fi
    
    else
        echo "Skipping from cloning rollback . . . "
    fi 
}

function _installLibVips(){
    
    echo ""
    echo "Installing imgproxy's dependency ..."
    echo "After this operation, libvips will be installed on your device ."
    _makeLogTitle "Install Libvips"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        if ! command -v libvips &> /dev/null; then
            sudo apt-get install libvips-dev 2>> error.logs
        else
            echo 'libvips is already installed.'
        fi

        
        if [ $? -eq 0 ]; then
            echo -e "${green}Installing Libvips done successfully"
            _backToDefaultColor
        else
            echo -e "${red}Failed to installing Libvips. You can see in error.logs why installing failed."
            _backToDefaultColor
            _rollBackInstallingLibVips
        fi
    
    else
        echo "Skipping installing Libvips ..."
    fi
}

function _rollBackInstallingLibVips(){
    
    echo ""
    echo "Roll back installing imgproxy's dependency..."
    echo "After this operation, Libvips code will be removed from its directory in your system."
    _makeLogTitle "Rollback installing Libvips"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        sudo apt purge libvips-dev 2>> error.logs

        
        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback installing imgproxy's dependency done successfully ."
            _backToDefaultColor
            _installLibVips
        else
            echo -e "${red}Failed to rollback cloning imgproxy. You can see in error.logs why rollback failed."
            _backToDefaultColor
            exit 1
        fi
    
    else
        echo "Skipping from installing imgproxy's dependency rollback . . . "
    fi 
}

function _installGolangCompiler(){
    
    echo ""
    echo "Installing Golang compiler ..."
    echo "After this operation, Golang will be installed on your device ."
    _makeLogTitle "Install Golang"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        if ! command -v go &> /dev/null; then
            sudo apt-get -y install golang 2>> error.logs
        else
            echo 'Golang is already installed.'
        fi

        
        if [ $? -eq 0 ]; then
            echo -e "${green}Installing Golang done successfully"
            _backToDefaultColor
            sleep 10
        else
            echo -e "${red}Failed to installing Golang. You can see in error.logs why installing failed."
            _backToDefaultColor
            _rollBackInstallingGolang
        fi
    
    else
        echo "Skipping installing Golang ..."
        sleep 10
    fi
}

function _rollBackInstallingGolang(){

    echo ""
    echo "Roll back installing Golang ..."
    echo "After this operation, Golang will be removed from your system."
    _makeLogTitle "Rollback installing Golang"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        sudo apt purge golang 2>> error.logs

        
        if [ $? -eq 0 ]; then
            echo -e "${green}Rollback installing Golang done successfully ."
            _backToDefaultColor
            _installGolangCompiler
        else
            echo -e "${red}Failed to rollback installing Golang. You can see in error.logs why rollback failed."
            _backToDefaultColor
            exit 1
        fi
    
    else
        echo "Skipping from installing Golang rollback . . . "
    fi 
}

function _rollbackAllConfigurations() {
    echo ""
    echo "Rolling back all configurations..."
    echo "After this operation, all configurations will be rolled back."
    _makeLogTitle "Rollback All Configurations"

    read -p "Do you want to continue? [Y/n] " response
    response=${response,,} # Convert response to lowercase

    if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
        
        sudo rm -r /opt/project 2>> error.logs

        sudo apt purge libvips-dev 2>> error.logs

        sudo apt purge golang 2>> error.logs

        echo -e "${green}Rollback all configurations done successfully."
        _backToDefaultColor

    else
        echo "Skipping rollback all configurations..."
    fi
}


. "bash-menu.sh"

actionA() {
    echo "Running Script ..."
    _deleteErrorLog
    _cloningImgProxy
    _installLibVips
    _installGolangCompiler
    sleep 20
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

exit 0
