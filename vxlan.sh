#!/bin/bash
if ovs-vsctl show; then
  echo "Openvswitch installed continuing.."
else
  echo "Please install openvswitch and make sure it is running."
  exit
fi
echo -e "Please enter the bridge name: "
read -r bridge_name
echo -e "Please enter the remote IP: "
read -r remote_ip
if ip route get 10.10.10.100 > /dev/null 2>&1; then
  echo "Valid Ip entered continuing.."
else
  echo "Invalid IP format entered."
  exit
fi
if ovs-vsctl add-br "$bridge_name"; then
  echo "Created the bridge $bridge_name successfully."
else
  echo "Failed to create bridge."
  exit
fi
ip=$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}')
if ovs-vsctl add-port $bridge_name vxlan0 -- set interface vxlan0 type=vxlan options:local_ip=$ip options:remote_ip=$remote_ip; then
  echo "Created link on this host successfully."
else
  echo "Failed to create VXLAN tunnel on this host."
  exit
fi
echo "Enter the IP to setup the tunnel on:"
 read -r br_ip
 if ifconfig "$bridge_name" "$br_ip"; then
   echo "Added IP to the bridge $bridge_name"
 else
   echo "Failed to add IP to the bridge."
   exit
 fi
