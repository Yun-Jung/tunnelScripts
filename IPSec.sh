#!/bin/bash

if ovs-vsctl show; then
  echo "Openvswitch installed continuing.."
else
  echo "Please install openvswitch and make sure it is running."
  exit
fi
echo -e "Please enter the bridge name IP: "
read -r bridge_name
echo -e "Please enter the remote IP: "
read -r remote_ip
if ip route get "$remote_ip" > /dev/null 2>&1; then
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
echo "Enter the IP to setup the tunnel on:"
read -r br_ip
if ip route get "$br_ip" > /dev/null 2>&1; then
  echo "Valid Ip entered continuing.."
else
  echo "Invalid IP format entered."
  exit
fi
ip addr add "$br_ip" dev "$bridge_name"
ip link set "$bridge_name" up
echo "Creating the certificate with hostname."
ovs-pki req -u "$HOSTNAME"
ovs-pki self-sign "$HOSTNAME"
echo "Copy the generated certificate with hostname to the remote machine where you will run the script."
read -pr "Press any key to continue... " -n1 -s
echo "Enter the hostname of the remote machine:"
read -r remote_hostname
ovs-vsctl set Open_vSwitch . \
           other_config:certificate=./{"$HOSTNAME"}-cert.pem \
           other_config:private_key=./{"$HOSTNAME"}-privkey.pem
ovs-vsctl add-port br-ipsec tun -- \
            set interface tun type=gre \
                   options:remote_ip="$remote_ip" \
                   options:remote_cert=./"$remote_hostname"-cert.pem


