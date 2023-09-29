#! /bin/bash

# Author: Mohammad Saleh Govahi
# Created: September 27 2023
# Last Modified: September 27 2023
# Description: A script for cloning script of phase 1 of Emperor Penguin project.
# Usage: sudo bash MainScriptPhase1.sh OR sudo ./MainScriptPhase1.sh


function _makeLogTitle(){
    echo "" >> error.logs
    echo "#-----------------------$1--------------------------------#" >> error.logs
    echo "" >> error.logs
}


if [[ $EUID -eq 0 ]]; then

    ping -c 1 8.8.8.8 >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        
        if ! command -v git &> /dev/null; then
            
            echo "Git is not installed on your system. To continue running this script, you should install Git on your system."
            read -p "Do you want to install it? [Y/n] " response
            response=${response,,}

            # If the user wants to install git, install it
            if [[ $response =~ ^(y| ) ]] || [[ -z $response ]]; then
                
                sudo apt-get -y install git > /dev/null 2>&1

            else
                echo "Skipping from this step is not allowed."
                echo "You should have Git to continue running script."
                exit 1
            fi
        fi
        
        sudo rm -r EmperorPenguinProject > /dev/null 2>&1
        echo "Cloning Project ..."
        _makeLogTitle "Cloning project" 
        git clone https://github.com/SalehGovahi/EmperorPenguinProject.git --branch Phase2
        cd EmperorPenguinProject
        sudo bash Phase2.sh

    else
        echo "You should connect to the internet to run this script. Try again later."
    fi
else
    echo "This script must be run as root."
    exit 1
fi