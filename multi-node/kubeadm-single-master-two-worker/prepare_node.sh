#!/bin/sh

# Update installed packages
echo "----------- Update installed packages -----------"
yum update -y
echo "----------- Update installed packages done -----------"
# Install additional packages
echo "----------- Install additional packages -----------"
yum -y install net-tools telnet 
echo "----------- Install additional packages done -----------"
# Prepare host for K8s
echo "----------- Prepare host for K8s -----------"
## Disable SELinux enforcement.
setenforce 0
## Disable SELinux enforcement. (permanently)
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
## Enable transparent masquerading and facilitate Virtual Extensible LAN (VxLAN) traffic for communication between Kubernetes pods across the cluster.
cat <<-'EOF' > /etc/modules-load.d/br_netfilter.conf
br_netfilter
EOF

modprobe br_netfilter

## Enable IP masquerade at the firewall
firewall-cmd --add-masquerade --permanent
firewall-cmd --reload

## Set bridged packets to traverse iptables rules.
cat <<-'EOF' > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

### Load the new rules
sysctl --system

## Disable all memory swaps to increase performance.
swapoff -a

echo "----------- Prepare host for K8s done -----------"

# Install Docker as Container Runtime
echo "----------- Install Docker -----------"
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
echo "----------- Install Docker done -----------"

echo "----------- Configure Docker -----------"
## Configure the Docker daemon
mkdir /etc/docker
cat <<EOF | tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
## Restart Docker and enable on boot
systemctl enable docker
systemctl daemon-reload
systemctl restart docker
echo "----------- Configure Docker done -----------"

echo "----------- Verify Docker -----------"
## Verify Docker
docker run hello-world
echo "----------- Verify Docker done -----------"

# Install kubelet, kubeadm, kubectl
echo "----------- Install kubelet, kubeadm, kubectl -----------"
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubelet-1.20.5-0 kubeadm-1.20.5-0 kubectl-1.20.5-0
systemctl enable kubelet

yum -y install yum-versionlock
yum versionlock add kubelet kubeadm kubectl

echo "----------- Install kubelet, kubeadm, kubectl done-----------"

# Pull K8s images (optional)
kubeadm config images pull