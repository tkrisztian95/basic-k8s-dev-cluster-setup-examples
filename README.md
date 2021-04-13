# Setup your Dev Kubernetes Cluster examples on Windows
In this repo you can find guidance and helping resources to quickstart your own Kubernetes (dev purpose only) cluster locally on Windows.

## Pre-requisites

- Docker for Windows installed
- Vagrant with VirtualBox installed
- Kubernetes fundamentals

## Objectives covered

- Setup single node Kubernetes cluster:
    - Using DockerDesktop (via simply enabling K8s feature)
    - Using VM with K3s preinstalled (Rancher's install script)
- Setup multi node Kubernetes cluster:
    - Using VMs (Docker preinstalled) with `kubeadm`

### FAQ

#### Single VS Multi-Node Cluster

In case of a Single Node K8s cluster, every Kubernetes component (both master and worker services) are running on a single machine. The replication factor is 1 due to only this, single node available to accept deployments. Which, means when the machine is down, your entire cluster is down. No recovery until the host machine is back.
However, in case of a Multi Node setup there are separated master and worker nodes. These nodes are the host machines, connected to each other and provides a transparent, horizontally scalable host. Depending on the host's role they are running different K8s controller services that enables you to deploy your application in the form of Docker containers. Having separated master and worker role nodes enables us to decouple control logic and achieve high availability with reduced cost. Usually, depending on your cluster size the master nodes do not require so much CPU or RAM and only running K8s services. The worker nodes accepts your deployments of your application and exposing your services. In case one of the worker nodes get crashed, your cluster is still available and can utilize the host machine's resources to recover your services that are currently down due to the system failure.

### Links & Other resources
- To get the current Kubernetes stable release version simply: http://storage.googleapis.com/kubernetes-release/release/stable.txt
TODO