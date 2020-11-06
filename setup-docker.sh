#!/bin/bash
# script that runs
# https://kubernetes.io/docs/setup/production-environment/container-runtime

rm -r /var/lib/apt/lists/*
apt update -y
apt clean -y
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# notice that only verified versions of Docker may be installed
# verify the documentation to check if a more recent version is available

apt update -y
apt install -y docker-ce docker-ce-cli containerd.io
[ ! -d /etc/docker ] && mkdir /etc/docker

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

# UPDATE NODES FOR YOUR ENV AND UNCOMMENT
cat >> /etc/hosts << EOF
{
  10.10.15.140 reidk8s01 control1
  10.10.15.141 reidk8s02 control2
  10.10.15.142 reidk8s03 control3
  10.10.15.143 reidk8s04 worker1
  10.10.15.144 reidk8s05 worker2
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

systemctl daemon-reload
systemctl restart docker
systemctl enable docker

systemctl disable --now firewalld
