*** Settings ***
Library    SSHLibrary
# Resource    verify-vm-creation.robot

*** Variables ***
${VM_IP}        172.18.0.191
${HOST_IP}      172.18.0.188
${VM_USR}       dan
${VM_PWD}       @Crown6562
${HOST_USR}     graid
${HOST_PWD}     GR@IDt1ch
${DEV_IP}       172.31.64.31     #richard dev 
${DEV_USR}      rbromley
${DEV_PWD}      passwd123

*** Test Cases ***
#Host Login 
#    Perform Login    ${HOST_IP}    ${HOST_USR}    ${HOST_PWD}   HOST

Client Login
    Perform Login    ${VM_IP}    ${VM_USR}    ${VM_PWD}    CLIENT

Dev Login
    Perform Login    ${DEV_IP}    ${DEV_USR}   ${DEV_PWD}    DEV

# Check if internet connected 
Internet Connection
#    Verify Internet Available
#    Switch Connection    HOST 
    Verify Internet Available
    Switch Connection    CLIENT
    Verify Internet Available

# check if host is connected to internet and have firewall enabled and ssh 
# Host Network Verify
#    Switch Connection    HOST  
#    Connected to Internet and Dependencies Available   ${HOST_IP}    eno1np0

# check if client is connected to internet and have firewall enabled and ssh 
Client Network Verify 
    Switch Connection    CLIENT 
    Connected to Internet and Dependencies Available    ${VM_IP}    enp1s0

Dev Network Verify
    Switch Connection    DEV
    Connected to Internet and Dependencies Available    ${DEV_IP}    enP7s7

# verify host 22 and client 22 is open 
Port 22 Available
#    Port Open
#    Switch Connection    HOST
    Port Open
    Switch Connection    DEV

# check for HOST / DEV machine but not VM
Verify NVMe OR SATA Exists 
    Verify NVMe Exists
    Verify SATA Exists
#    Switch Connection    Host
#    Verify NVMe Exists
#    Verify SATA Exists

NVIDIA GPU Available
#    Verify GPU Exists
    Switch Connection    CLIENT
    NVIDIA Driver Equipped
    Verify GPU Exists
    Switch Connection    DEV
    NVIDIA Driver Equipped
    Close All Connections

# check available memory is greater than 500 mb for both host / client (siwtch connection built in)

*** Keywords ***
Perform Login
    [Arguments]    ${ip}  ${usr}  ${pwd}  ${alias}
    Open Connection    ${ip}   alias=${alias}
    Login    ${usr}    ${pwd}

Verify Internet Available
    ${Internet_connection}=   Execute Command    ping -c 4 8.8.8.8
    Should Contain    ${Internet_connection}    4 received

Connected to Internet and Dependencies Available 
    [Arguments]    ${cur_ip}    ${interface_id}
    ${internet}=    Execute Command    ip addr show ${interface_id}
    Should Contain    ${internet}    inet ${cur_ip}

    ${firewall}=    Execute Command    systemctl status ufw
    Should Contain    ${firewall}    active

    ${ssh}=         Execute Command    systemctl status ssh
    Should Contain    ${ssh}    active

# verify port 22 is open
Port Open 
    ${port_status}=    Execute Command    netstat -plan | grep :22 
    Should Contain    ${port_status}    LISTEN

# check if nvme ssd exists: host/server only 
Verify NVMe Exists 
    ${lsblk_output}=    Execute Command    lsblk
    # Log To Console    ${lsblk_output} 
    # ${nvme_found}=    Should Contain    ${lsblk_output}    nvme
    ${nvme_found}=      Evaluate   'nvme' in $lsblk_output

    Run Keyword If    ${nvme_found} == True
    ...    Log To Console    NVMe drive Found 
    ...  ELSE
    ...    Log To Console    NVMe drive NOT found 
# SATA
Verify SATA Exists
    ${lsblk_output}=    Execute Command    lsblk
    # Log To Console    ${lsblk_output} 
    ${sata_found}=    Evaluate    'sda' in $lsblk_output or 'sdb' in $lsblk_output

    # Run Keyword If     'sda'  in  '${lsblk_output}'  or  'sdb' in '${lsblk_output}'
    Run Keyword If     ${sata_found} == True 
    ...    Log To Console    SATA Exists 
    ...    ELSE   Log To Console    SATA is NOT FOUND 
    
Verify GPU Exists 
    ${nvidia_gpu_exists}=    Execute Command    lspci | grep -i nvidia
    Should Contain    ${nvidia_gpu_exists}    NVIDIA Corporation

# check if nvidia driver is installed: vm usage 
NVIDIA Driver Equipped 
    ${dpkg_output}=     Execute Command    dpkg -l | grep nvidia-driver
    Should Contain    ${dpkg_output}    NVIDIA driver

# check GPUs are unbinded: host / server only 
# VFIO verify
#     ${vfio_pci}=     Execute Command    lspci -nnk | grep -i --color 'vga' -A3
#     Should Contain    ${vfio_pci}    Kernel driver in use: vfio_pci

# for loop condition -> check while running all id's => it contains the msg kernel driver in use: vfio_pci 
# for it to run every id 
# verify that the driver is using vfio_pci 


#DHCP check only for client/workstation - or temporary test -> unncessary check 
