#!/bin/bash

# Update available packages
yum update -y

# Install Standard Dev tools
echo '===== Installing Standard Dev tools'
yum install -y git

# Install Kubernetes using K3s
# See more: https://rancher.com/docs/k3s/latest/en/quick-start/
echo '===== Installing K3s'
export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC="--node-name k3s-dev-node --flannel-iface=eth1 --node-ip=192.168.33.10"
curl -sfL https://get.k3s.io |  sh -   