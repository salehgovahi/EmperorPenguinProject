[![Available_in](https://img.shields.io/badge/-Available%20in-555)]()
[![Linux](https://img.shields.io/badge/-LINUX-blue)](https://www.debian.org/)

# Emperor Penguin Project
## What is in repository?
This is a repository for EmperorPenguin's project in EmperorPenguin course at [Part Software Group](https://www.partsoftware.com/)
## How to run ?
To run this script on your linux system you can easily run it with this command:

### Phase 1:

    
    sudo bash -c 'bash <(curl -s https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/main/MainScriptPhase1.sh)'

## 

### Phase 2:

On Host

    sudo bash -c 'bash <(curl -s https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/main/SSHToVirtualMachine.sh)'


On Virtual Machine

    sudo bash -c 'bash <(curl -s https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/main/MainScriptPhase2.sh)'

##

### Phase 3:

On Virtual Machine
    
    curl -sSfL https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/Phase3/Webserver.py | python3 -

On Host you can curl to the ip of virtual machine in 3 selection:

- ./run-script/
- ./check-script/
- ./rollback/

#

[About project](https://github.com/SalehGovahi/EmperorPenguinProject/wiki)
	
![](https://cms.partsoftware.com/images/cf302d4f-6029-4605-adcc-71835e6a0ddf.jpg)
