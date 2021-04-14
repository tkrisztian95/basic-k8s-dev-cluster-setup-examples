
# Setup a Multi-Node Kubernetes cluster using Kubeadm

**Prerequisites:**
- Vagrant installed with VirtualBox
    1. Install VirtualBox form: https://www.virtualbox.org/
    2. Install Vagrant from: https://www.vagrantup.com/

## Spinning up a CentOS 7 VMs with Docker pre-installed

Use the provided Vagrant file to start VMs with CentOS 7 linux distro. The Vagrantfile uses the shell provisioner to prepare each machine in this multi-machine setup.

The following packages will be installed on each node via the provisioning:
- Docker

The following Kubernetes components will be installed on each node via the provisioning:
- kubeadm
- kubelet 
- kubectl (communicating with the cluster)

Configured to keep all on the same version within the cluster.

**Note:** Check the provided `prepare_node.sh` for more details.

To start the VM:
```
PS> vagrant up
```

**Note:** *Takes ~3min*

To SSH into the master node VM:
```
PS> vagrant ssh master
```

To SSH into one of the worker node VM:
```
PS> vagrant ssh worker-<num>
```

## Set Up Cluster with Kubeadm (manually)

### Init Master Node
To init control plane on master node:
```
PS> vagrant ssh master
$ sudo su
$ kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=10.0.0.10
// Expected output:
...
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, ...
...
```
The output contains a copy-paste solution to join additional worker nodes into the cluster. Note it down for configuring `worker-1` and the `worker-2` VMs.

#### Example `kubeadm join` command
```
kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>
```

**Info:** *Kubernetes isn't listening to all interfaces by default. It picks the interface with the default gateway and listens to that. We use the `--api-advertise-addresses=<the eth1 ip addr>` flag in the `kubeadm init` step to use the host-only interface.*

### Configuring the Master Node

Set the `KUBECONFIG` environment variable.
```
export KUBECONFIG=/etc/kubernetes/admin.conf
```
Switch back to regular user
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Verify `kubectl` is working:
```
$ kubectl version
// Expected output:
Client Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.5", GitCommit:"6b1d87acf3c8253c123756b9e61dac642678305f", GitTreeState:"clean", BuildDate:"2021-03-18T01:10:43Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.5", GitCommit:"6b1d87acf3c8253c123756b9e61dac642678305f", GitTreeState:"clean", BuildDate:"2021-03-18T01:02:01Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"linux/amd64"}
```

Check the status of `kubelet`, should be `active (running)`:
``` diff
$ systemctl status kubelet
// Expected output:
● kubelet.service - kubelet: The Kubernetes Node Agent
   Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; vendor preset: disabled)
  Drop-In: /usr/lib/systemd/system/kubelet.service.d
           └─10-kubeadm.conf
   Active: active (running) since Thu 2021-03-25 11:53:39 UTC; 11min ago
```

Verify the master node:
```
$ kubectl get nodes
//Expected output:
NAME                    STATUS     ROLES                  AGE     VERSION
master-control-plane-node   NotReady   control-plane,master   7m48s   v1.20.5
```
Notice that the node's `STATUS` is `NotReady`.
Try describe the node and check. 
```
$ kubectl describe node master-control-plane-node
```
Find the following message line in the `Conditions`:
```
...
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
Ready            False   Thu, 25 Mar 2021 11:58:58 +0000   Thu, 25 Mar 2021 11:53:33 +0000   KubeletNotReady              runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
```
Fix this in the following section with deploying [Calico](https://www.projectcalico.org/).
#### Deploy the POD Network 
Check the coredns pods status:
```
$ kubectl get pods --all-namespaces
// Expected output:
NAMESPACE     NAME                                            READY   STATUS    RESTARTS   AGE
kube-system   coredns-74ff55c5b-n52mv                         0/1     Pending   0          17m
kube-system   coredns-74ff55c5b-nhcqw                         0/1     Pending   0          17m
...
```
Notice that the pods with name `coredns-<random>-<random>` are in `Pending` state instead of `Running`.

Lets download and apply the Calico networking manifest for the Kubernetes API datastore.
```
$ curl https://docs.projectcalico.org/manifests/calico.yaml -O
$ kubectl apply -f calico.yaml
```

**Note:** *Need to pass --pod-network-cidr=192.168.0.0/16 to kubeadmin init, or update the calico.yml accordingly to your setup.*

Wait for the master node status switch to `Ready`:
```
$ kubectl get nodes -w
NAME                    STATUS     ROLES                  AGE   VERSION
master-control-plane-node   NotReady   control-plane,master   24m   v1.20.5
master-control-plane-node   NotReady   control-plane,master   25m   v1.20.5
...
master-control-plane-node   Ready      control-plane,master   26m   v1.20.5
CTRL+C
```

Check the coredns pods state again (wait for `Running`):
```
$ kubectl get pods --all-namespaces
// Expected output:
NAMESPACE     NAME                                            READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-69496d8b75-rms6h        1/1     Running   0          4m50s
kube-system   calico-node-597g2                               1/1     Running   0          4m51s
...
```
Now the coredns pods should be in `Running` state.

Let's describe the node again:
```
$ kubectl describe node master-control-plane-node
```

Find the following line to ensure that `CalicoIsUp`:
```
Conditions:
  Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----                 ------  -----------------                 ------------------                ------                       -------
  NetworkUnavailable   False   Thu, 25 Mar 2021 12:18:41 +0000   Thu, 25 Mar 2021 12:18:41 +0000   CalicoIsUp                   Calico is running on this node
```

See more: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network

#### Verify component status
```
$ kubectl get componentstatuses
// Expected output:
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-0               Healthy   {"health":"true"}
```

##### Troubleshoot:
In case of executing command `kubectl get componentstatuses` gives the following output:
```
NAME                 STATUS      MESSAGE                                                                                       ERROR
scheduler            Unhealthy   Get "http://127.0.0.1:10251/healthz": dial tcp 127.0.0.1:10251: connect: connection refused
controller-manager   Unhealthy   Get "http://127.0.0.1:10252/healthz": dial tcp 127.0.0.1:10252: connect: connection refused
etcd-0               Healthy     {"health":"true"}
``` 
Resolve with:
```
// Clear the line (spec->containers->command) containing this phrase: - --port=0
sudo vi /etc/kubernetes/manifests/kube-scheduler.yaml
// Clear the line (spec->containers->command) containing this phrase: - --port=0
sudo vi /etc/kubernetes/manifests/kube-controller-manager.yaml
// Restart service
sudo systemctl restart kubelet.service
```

See: https://stackoverflow.com/questions/64296491/how-to-resolve-scheduler-and-controller-manager-unhealthy-state-in-kubernetes

#### Verify firewalld is turned off

```
sudo firewall-cmd --state
// Expected output:
not running
```

### Join Worker Nodes to the Cluster
To ssh into the worker node `worker-1` 
```
PS> vagrant ssh worker-1
```
and join to the cluster:
```
$ sudo su
// Paste the line from the master kubeadm init command output (as root)
// Example (use the one that you noted down):
$ kubeadm join --token <token> 10.0.0.10:6443 --discovery-token-ca-cert-hash sha256:<hash>
```
**Note:** *In case you forgot to note the join command execute this on the master again `kubeadm token create --print-join-command` to get another one.* 

**Note:** *In case it stuck at `Running pre-flight check` try checking firewall state on the master node with command `sudo firewall-cmd --state`.*

See more at: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

On a second terminal SSH to the master:
```
$ kubectl get nodes
NAME                        STATUS   ROLES                  AGE    VERSION
master-control-plane-node   Ready    control-plane,master   12m    v1.20.5
worker-node-1               Ready    <none>                 3m3s   v1.20.5
```
Notice that in the line of the node `worker-node-1` the `Roles` column contains value `<none>` means that the node doesn't have any `Roles` specified.
Use the following command to set a `worker` role label for it:
```
$ kubectl label node worker-node-1 node-role.kubernetes.io/worker=worker
```
Verify the changes:
```
$ kubectl get nodes
// Expected output:
NAME            STATUS   ROLES                  AGE     VERSION
master-node     Ready    control-plane,master   13m     v1.20.5
worker-node-1   Ready    worker                 6m19s   v1.20.5
```

At this point you should see the node with name `worker-node-1` in the list with role `worker`.

Follow the same process to add more worker nodes.

### Verify the Kubernetes cluster is ready
To ensure that our Kubernetes cluster is ready we are going to create a deployment with a web server running in our cluster and listening on port 80.

Use the following command to deploy Nginx into the cluster:
```
$ kubectl create deployment nginx --image=nginx
$ kubectl describe deployment nginx
```
Create a service to expose Nginx externally through a node port:
```
$ kubectl create service nodeport nginx --tcp=80:80
```
Try reach the default webserver page from your browser:
```
$ kubectl get services
curl 10.102.246.1:80
```

## Related Links & Resources
Vagrant multimachine docs: https://www.vagrantup.com/docs/multi-machine