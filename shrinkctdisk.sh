#!/bin/bash

# List containers
CONTAINERS=$(pct list | awk 'NR>1 {print $1 " " $2}')

# Ask user to select a container
CTID=$(whiptail --title "Container selection" --menu "Choose a container to resize" 20 60 10 ${CONTAINERS} 3>&1 1>&2 2>&3)

# Stop container
pct stop ${CTID}

# Find out container's path on the node
LV_PATH=$(lvdisplay | grep "LV Path" | awk '{print $3}')

# Run a file system check
e2fsck -fy ${LV_PATH}

# Ask user for new size
NEWSIZE=$(whiptail --inputbox "Enter new size (e.g., 10G)" 8 78 --title "Disk resize" 3>&1 1>&2 2>&3)

# Resize the file system
resize2fs ${LV_PATH} ${NEWSIZE}

# Resize the local volume
lvreduce -L ${NEWSIZE} ${LV_PATH} --yes

# Edit container's conf
sed -i "s/size=[0-9]*G/size=${NEWSIZE}/g" /etc/pve/lxc/${CTID}.conf

# Start container
pct start ${CTID}

# Inform user
whiptail --title "Disk resize" --msgbox "Disk resize successful!" 8 78
