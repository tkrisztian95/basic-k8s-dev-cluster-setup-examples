# Setup a Single-Node Kubernetes Cluster with K3s

[K3s](https://k3s.io/) is a certified, lightweight prod ready Kubernetes distribution by Rancher. Very easy to set up using the quickstart installation script.

See more: https://rancher.com/docs/k3s/latest/en/

**Prerequisites:**
- Vagrant installed with VirtualBox
    1. Install VirtualBox form: https://www.virtualbox.org/
    2. Install Vagrant from: https://www.vagrantup.com/
     
## Spinning up a CentOS 7 VM with K3s pre-installed

Use the provided Vagrant file to start a VM with CentOS 7 linux distro. The Vagrantfile uses the shell provisioner to get the K3s install script from the remote source and execute it when the VM starts.

### Basic Vagrant commands 
To start the VM:
```
PS> vagrant up
```

**Note:** *Takes ~30sec*

To SSH into the VM:
```
PS> vagrant ssh
```

### Get Started
To check the installed k3s version:
```
$ k3s --version 
// Expected output:
k3s version v1.20.4+k3s1 (838a906a)
go version go1.15.8
```

**Note:** In the k3s version schema the `v1.20.4` part refers to the packaged Kubernetes version. 

To verify `kubectl` is working and you K3s single-node cluster is ready:
```
$ kubectl get nodes
// Expected output
NAME           STATUS   ROLES                  AGE    VERSION
k3s-dev-node   Ready    control-plane,master   105s   v1.20.4+k3s1
```

### Tear Down
Exit from VM:
```
$ exit
```

To delete the VM:
```
PS> vagrant destroy
```

**Note:** *Don't forget to `cd` into the directory where the `Vagrantfile` is.*