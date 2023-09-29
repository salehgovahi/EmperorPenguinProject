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

_makeLogTitle "Cloning project"
git clone -b Phase1 https://github.com/SalehGovahi/EmperorPenguinProject.git 2>> error.logs >/dev/null
cd EmperorPenguinProject
sudo bash Phase1.sh
