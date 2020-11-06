#!/bin/bash
# kubeadm installation instructions as on
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# disable swap (assuming that the name is /dev/mapper/ubuntu1804packer--vg-swap_1)
sed -i '\/dev\/mapper\/ubuntu1804packer--vg-swap_1/d' /etc/fstab
# swapoff /dev/mapper/ubuntu1804packer--vg-swap_1
swapoff -a

modprobe br_netfilter

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt clean -y
apt update -y
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet

# Set iptables bridging
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
