[![Available_in](https://img.shields.io/badge/-Available%20in-555)]()
[![Linux](https://img.shields.io/badge/-LINUX-blue)](https://www.debian.org/)

# Emperor Penguin Project
## What is in repository?
This is a repository for EmperorPenguin's project in EmperorPenguin course at [Part Software Group](https://www.partsoftware.com/)
## Requirments
To run this script on your linux system you can easily run it with this command:

    
    wget -O - https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/main/Bash.sh | bash

## 

## Project description :

Saber is a sys admin in part software group. He uses Open-source tools in self-hosted mode to meet the needs of company .He haS ruuned tools lika **grafana** and **prometheus** in self-hosted mode several times manually and by entering various commands until he was asked to use the imgproxy tool in company environment.This time he decided to create automatic process to use at first for imgproxy and use for other Open-source tools in company .I write my way in this project and descript commands that I use for this project here .

### First Phase(Preparation of test environment with virtual machine) :

At first i installed a **Debian version 11 netinstall** as virtual machine in vmware. I should add that I have a Debian 12 in my computer as a dual boot operating system .

I should describe functions that i use frequently in other functions :

1.  **\_deleteSubFolders** :
    
    ```bash
    function _deleteSubFolders() {
    echo "Preparing requirements ..."
    sudo rm -r Backup/ >/dev/null 2>&1 
    sudo rm -r ConfigSettings/ >/dev/null 2>&1
    }
    ```
    
    This function removes all sub folders that me be in directory exists to prevent conflicts with new settings and backups .
    
2.  **\_makeBackupFolder** :
    
    ```bash
    function _backupfile() {  	
        sudo cp $1 $(pwd)/Backup
    }
    ```
    
    This function make a folder for backup files .
    
3.  **\_backupFile** :
    
    ```bash
    function _backupfile() {  	
        sudo cp $1 $(pwd)/Backup
    }
    ```
    
    This function make a backup from file that we should config befor configuring to have a backup from file for the time if a problem  
    happen or our config may not true.
    
4.  **\_makeErrorLog** :
    
    ```bash
    function _makeErrorLog(){
       sudo rm error.logs >/dev/null 2>&1 >/dev/null
       sudo touch error.logs
       echo "Error happend while running script :" > error.logs
    }
    ```
    
    This function make an error.logs file to redirected errors from commands .
    
5.  **\_makeLogTitle** :
    
    ```bash
    function _makeLogTitle(){
       echo "" >> error.logs
       echo "#-----------------------$1--------------------------------#" >> error.logs
       echo "" >> error.logs
    }
    ```
    
    This function make title for each function in error.logs to see the errors better .
    

These are steps that we should do in First Phase and my ways to do them :

1.  Set Debian sources in /etc/apt/sources.list to official sources of Debian version 11 :
    
    ```bash
    function \_setRepository() {
    
        echo ""  
        echo "Setting repository addresses ..."  
        echo "After this operation, repository sources will be set to official repository addresses of Debian."  
        \_makeLogTitle "Setting repository :"
    
        read -p "Do you want to continue? \[Y/n\] " response  
        response=${response,,} # Convert response to lowercase
    
        if \[\[ $response =~ ^(y| ) \]\] || \[\[ -z $response \]\]; then
            
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
    ```
    
    At first show a descripton of function doing and get user answer to do it or skip over it.  
    This function at first check if Sources.txt file is exists on folder ConfigSetttings and if it exists first make a backup from existing source in Backup folder and after that replace our sources in sources.list and update resources after that . Finally check if commands done successfully or not and show related massages .
    
2.  Setting NTP service with given url :
    
    ```bash
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
    ```
    
    At first show a descripton of function doing and get user answer to do it or skip over it.  
    This function at first check if NTPConfig.txt file is exists on folder ConfigSetttings and if it exists first install ntp service, second make a backup from existing ntp configue file in Backup folder and after that replace data in /etc/ntp.conf with NTPConfig.txt and after that restart ntp service to apply changes. Finally check if commands done successfully or not and show related massages .
    
3.  Making user with an expire time for user and an expire time for user's password :
    
    ```
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
    ```
    
    At first show a descripton of function doing and get user answer to do it or skip over it.  
    This function make a user with password:secret123 with the help of flag -p in useradd command and set expire time for it with flag -e of command useradd to a month later.And after that with command chage and its flag -E set an expire date for password for a week later. Finally check command if done successfully or not and show related massage .
    
4.  Changing root's password :
    
    ```bash
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
    ```
	At first show a descripton of function doing and get user answer to do it or skip over it.  
	This function changes root user's password from any password that is existing to Toor321 with redirecting root:Toor321 to command chpasswd. Finally check command if done successfully or not and show related massage .
5. Installing Git :
	```
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
	```
	At first show a descripton of function doing and get user answer to do it or skip over it.  
	This function installs Git from repository sources with command apt-get and flag -y . Why using -y flag ? Beacuse to say yes automatically to prompts and force to install package . Finally check command if done successfully or not and show related massage .
6. Write a script that shows all command of processes with PID less than 2000 and runned them user root :
	```
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
	```
	At first show a descripton of function doing and get user answer to do it or skip over it.  
	This function writes a script to show wanted informations with command ps with flags -U (running by root user) , -o (only show PID and command to filter easily) and --no-headers (not show normall headers of ps command)  . Finally check command if done successfully or not and show related massage .
	
![](https://partsoftware.com:5000/images/cf302d4f-6029-4605-adcc-71835e6a0ddf.jpg)
