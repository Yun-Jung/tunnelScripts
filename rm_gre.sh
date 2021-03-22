#!/bin/bash
if ovs-vsctl show; then
  echo "Openvswitch installed continuing.."
else
  echo "Please install openvswitch and make sure it is running."
  exit
fi

echo -e "Please enter the bridge name you want to remove: "
read -r bridge_name

if ovs-vsctl del-br "$bridge_name"; then
  echo "Removed the bridge $bridge_name successfully."
else
  echo "Failed to remove bridge."
  exit
fi
