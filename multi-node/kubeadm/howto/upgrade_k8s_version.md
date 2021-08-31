# How do I update Kubernetes version?

Upgrade workflow:

1. Upgrade the primary control plane node first.
2. Upgrade additional control plane nodes.
3. Upgrade the worker nodes finally.

_note:_ Before updating a node it should be drained first!

_note:_ Before start, check the installed K8s and kubeadm version with command `kubeadm version`. To list all available `kubeadm` versions and find the latest version for upgrade to, run this list command: `yum list --showduplicates kubeadm --disableexcludes=kubernetes`

Commands to use for upgrading `master` or further control plane nodes:

0. Upgrade `kubeadm` with `yum install -y kubeadm-1.XX.X-0 --disableexcludes=kubernetes` first.
1. Use the `kubectl drain` command to drain out pods from the node.
2. Use the `kubeadm upgrade plan` command to plan the version upgrade. List the available and current version for the K8s components. At the end it has given on the output a command to perform the upgrade.
3. Use the provided `kubeadm upgrade apply v1.XX.X` command to perform the upgrade.
4. Once the upgrade was successful, we can uncordon the master node with command `kubectl uncordon <node-name>`, to let the scheduler schedule pods on it again.
5. Verify upgrade was successful:
    a. Check versions with `kubelet --version` and `kubectl version`
    b. Try install a newer version of kubelet and kubectl with `yum install -y kubelet-1.XX.X-0 kubectl-1.XX.X-0 --disableexcludes=kubernetes`.

Commands to use for upgrading worker nodes:

0. Upgrade `kubeadm` with `yum install -y kubeadm-1.XX.X-0 --disableexcludes=kubernetes` first.
1. Use the `kubectl drain` command to drain out pods from the node.
2. Install a newer version of kubelet and kubectl with `yum install -y kubelet-1.XX.X-0 kubectl-1.XX.X-0 --disableexcludes=kubernetes`.
3. Lastly kubelet needs to restart on the worker nodes: `systemclt restart kubelet`.

Once we are done with upgrading all of our K8s cluster nodes, use the `kubectl get nodes` command on the master node to verify the status of the cluster and the nodes are on the same version.