#!/bin/bash

# List of Container IDs to resize
CONTAINER_IDS=("101" "102" "103")

for CTID in "${CONTAINER_IDS[@]}"
do
  # Stop container
  pct stop ${CTID}

  # Find out container's path on the node
  LV_PATH=$(lvdisplay | grep "LV Path" | awk '{print $3}')

  # Run a file system check
  e2fsck -fy ${LV_PATH}

  # Ask user for new size
  NEWSIZE=$(whiptail --inputbox "Enter new size for container ${CTID} (e.g., 10G)" 8 78 --title "Disk resize" 3>&1 1>&2 2>&3)

  # Resize the file system
  resize2fs ${LV_PATH} ${NEWSIZE}

  # Resize the local volume
  lvreduce -L ${NEWSIZE} ${LV_PATH} --yes

  # Edit container's conf
  sed -i "s/size=[0-9]*G/size=${NEWSIZE}/g" /etc/pve/lxc/${CTID}.conf

  # Start container
  pct start ${CTID}

  # Inform user
  whiptail --title "Disk resize" --msgbox "Disk resize for container ${CTID} successful!" 8 78
done
