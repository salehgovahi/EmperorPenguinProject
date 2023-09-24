#! /bin/bash

# Author: Mohammad Saleh Govahi
# Created: September 24 2023
# Last Modified: September 24 2023
# Description: A script for clone files of phase 2 of Penguin Emperor project .
# Usage: bash MainScript.sh OR ./MainScript.sh

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
        
        echo "Cloning Project ..."
        git clone https://github.com/SalehGovahi/EmperorPenguinProject.git
        cd EmperorPenguinProject
        sudo bash BashSettingUpImgproxy.sh

    else
        echo "You should connect to the internet to run this script. Try again later."
    fi
else
    echo "This script must be run as root."
    exit 1
fi