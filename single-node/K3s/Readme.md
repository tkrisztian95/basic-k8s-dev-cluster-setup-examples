# Setup a Single-Node Kubernetes Cluster with K3s

[K3s](https://k3s.io/) is a certified, lightweight prod ready Kubernetes distribution by Rancher. Very easy to set up using the quickstart installation script.

See more: https://rancher.com/docs/k3s/latest/en/
     
## Spinning up the CentOS 7 VM with K3s pre-installed

Use the provided Vagrant file to start a VM with CentOS 7 linux distro. The Vagrantfile uses the shell provisioner to get the K3s install script from the remote source and execute it when the VM starts.

To start the VM:
```
PS> vagrant up
```

**Note:** *It takes roughly ~5min to prepare the VM and install/update additional packages.*

To SSH into the VM:
```
PS> vagrant ssh
```

### Get Started with K3s
To check the installed k3s version:
```
$ k3s --version 
// Expected output:
k3s version v1.20.4+k3s1 (838a906a)
go version go1.15.8
```

**Note:** In the k3s version schema the `v1.20.4` part refers to the packaged Kubernetes version. 

To verify `kubectl` is working and your Kubernetes cluster is ready:
```
$ kubectl get nodes
// Expected output
NAME           STATUS   ROLES                  AGE    VERSION
k3s-dev-node   Ready    control-plane,master   105s   v1.20.4+k3s1
```

### Pre-installed Standard Dev tools

- [Git](https://git-scm.com/)
- [Krew](https://krew.sigs.k8s.io/)


## Networking

- The hostname is: `k3s-dev.local` 
- The private IP address is: `192.168.33.10`
  - Can be used for connecting from the host machine.

See more at: https://learn.hashicorp.com/tutorials/vagrant/getting-started-networking

### How to connect to a K8s pod running in the VM from the host

Example: Deploy a Hello world app example and use Kubernetes port-forwarding.

Run the following commands in the VM:
```
$ kubectl run kubernetes-first-app --image=gcr.io/google-samples/kubernetes-bootcamp:v1 --port=8080
$ kubectl port-forward pod/kubernetes-first-app 8080:8080 --address 0.0.0.0
// Expected output:
Forwarding from 0.0.0.0:8080 -> 8080
```

Check K8s port-forwarding works inside the VM, so you can reach the server running inside the pod:
```
// Open a second terminal (vagrant ssh)
$ curl localhost:8080
// Expected output:
Hello Kubernetes bootcamp! | Running on: kubernetes-first-app | v=1
```

Check can connect from the host:
To connect from the host machine to the pod running inside the K8s cluster on the VM, navigate to one of the URLs in your browser: 
- Using the VMs private IP address: http://192.168.33.10:8080, 
  -  It's fixed, defined in the Vagrantfile.
- or via http://localhost:8080 
  - With using Vagrant port-forward feature. Simply uncomment the line in the Vagrantfile: `config.vm.network :forwarded_port, guest: 8080, host:8080`

## Synced folders

Synced folders enable Vagrant to sync a folder on the host machine to the guest machine, allowing you to continue working on your project's files on your host machine.
[See more](https://www.vagrantup.com/docs/synced-folders)

By default, Vagrant will share your project directory (the directory with the Vagrantfile) to `/vagrant`.

### Where to find synced files?

- **Host:** This VM is configured to sync the `src` folder (the directory next to the Vagrantfile) with the guest machine. 

- **VM:** You can locate the synced resources in the guest machine at `/home/vagrant/src`.

**Note:** You can simply change the config to point to another source directory (relative or absolute) on your host or in the guest (absolute) anytime by editing the line `config.vm.synced_folder` in the Vagrantfile.

### Verify synced folders working
To verify your VM is picking up the files from the host `src` directory:

List all files and directories in the VM home directory:
```
[vagrant@localhost ~]$ ls -la
total 12
drwx------. 4 vagrant vagrant  85 Jun 28 14:37 .
drwxr-xr-x. 3 root    root     21 Apr 30  2020 ..
-rw-r--r--. 1 vagrant vagrant  18 Apr  1  2020 .bash_logout
-rw-r--r--. 1 vagrant vagrant 193 Apr  1  2020 .bash_profile
-rw-r--r--. 1 vagrant vagrant 231 Apr  1  2020 .bashrc
drwxrwxrwx. 1 vagrant vagrant   0 Jun 28 14:03 src        # <-- You should see
drwx------. 2 vagrant vagrant  29 Jun 28 14:34 .ssh
```

List the `src` dir content:
```
[vagrant@localhost src]$ ls -la ./src
total 0
drwxrwxrwx. 1 vagrant vagrant  0 Jun 28 14:03 .
drwx------. 4 vagrant vagrant 85 Jun 28 14:37 ..
-rwxrwxrwx. 1 vagrant vagrant  0 Jun 28 13:57 .gitkeep    # <-- You should see
```

On a second terminal: Create a new file with the name `Hello World` on the host in the `src/` directory.
```
PS single-node\K3s> echo $null >> src/"Hello World"
```

List the `src` dir content again:
```
[vagrant@localhost src]$ ls -la ./src
total 0
drwxrwxrwx. 1 vagrant vagrant  0 Jun 28 14:03 .
drwx------. 4 vagrant vagrant 85 Jun 28 14:37 ..
-rwxrwxrwx. 1 vagrant vagrant  0 Jun 28 13:57 .gitkeep    
-rwxrwxrwx. 1 vagrant vagrant  0 Jun 28 14:03 Hello World # <-- Now you should see this too
```

## Troubleshoot

Ensure your current working directory is where the Vagrantfile lives before executing the Vagrant commands. 

In case of errors try open your command window or terminal as privileged and recrating the VM with `vagrant destroy` and `vagrnat up`.

**Note:** You might need Super Administrator rights on the host to set up the VMs with specific features.