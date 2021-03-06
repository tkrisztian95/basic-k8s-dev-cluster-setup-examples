# Setup Dev Kubernetes Cluster on Windows

In this repo you can find resources to quickstart your Kubernetes (dev purpose only) cluster locally on Windows using VMs and Vagrant.

## Prerequisites

Install the following software on your host machine:

- [DockerDesktop for Windows](https://www.docker.com/products/docker-desktop)
- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)

### Vagrant Virtual Box guest plugin:
```
PS> vagrant plugin install vagrant-vbguest
```

## Objectives Covered

- Setup single-node Kubernetes cluster:
    - Simply enabling Kubernetes feature in Docker for Windows.
    - Start VM using Vagrant:
        - VagrantBox with K3s preinstalled.
- Setup multi-node Kubernetes cluster:
    - Start VMs using Vagrant:
        - VagrantBox with Docker and Kubernetes preinstalled (using `kubeadm`)

### FAQ

#### Single-Node VS Multi-Node Kubernetes Cluster

In case of a Single Node K8s cluster, every Kubernetes component (both master and worker services) are running on a single machine. The replication factor is 1 due to only this, single node available to accept deployments. So, when the machine is down, your entire cluster is down. No recovery until the host machine is back.

However, in case of a Multi-Node setup there are separated master and worker nodes. These nodes are the host machines, connected to each other and provides a transparent, horizontally scalable host. Depending on the host's role they’re running different K8s controller services that enable you to deploy your application in the form of Docker containers. Having separated master and worker role nodes enables us to decouple control logic and achieve high availability with reduced cost. Usually, depending on your cluster size the master nodes don’t require so much CPU or RAM and only running K8s services. The worker nodes accept your deployments of your application and exposing your services. In case one of the worker nodes get crashed, your cluster is still available and can utilize the host machine's resources to recover your services that are currently down due to the system failure.

#### Basic Vagrant Commands

To start the VM:

``` PowerShell
PS> vagrant up
```

**Note:** *Don't forget step into the directory where the `Vagrantfile` is placed.*

To SSH into the VM:

``` PowerShell
PS> vagrant ssh [name|id]
```
_see more about this `ssh` command:_ https://www.vagrantup.com/docs/cli/ssh


To check VMs exists or running on your host:
``` PowerShell
PS> vagrant global-status
```
_Use the `--prune` switch to avoid stale machines being listed._

To delete the VM:

``` PowerShell
PS> vagrant destroy [name|id]
```

#### Explore your Kubernetes cluster and its status

To explore and test your cluster is ready you can use the following basic `kubectl` commands after ssh into one of the VMs you have set up your Kubernetes cluster with.

To get the cluster information (execute on master node). Display the address of the cluster and further services.
```
$ kubectl cluster-info
```

To list all nodes in the cluster with their statuses. (_If a node status isn’t ready it indicates problem._)
```
$ kubectl get nodes
```

To list all events with timestamps:
```
$ kubectl get events
```

To list all the pods in the cluster:
```
$ kubectl get pods -o wide --show-labels --all-namespaces
```

### Troubleshooting

See the kubelet service logs running on the node:

```
$ journalctl --unit kubelet
```

### Links & Useful Resources

- To get the current Kubernetes stable release version simply: http://storage.googleapis.com/kubernetes-release/release/stable.txt