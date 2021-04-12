#### Configure Firewalld (master)
```
sudo firewall-cmd --state
// Expected output:
running
```
Start firewalld and configure rules:
```
$ systemctl start firewalld

$ firewall-cmd --permanent --add-port=6443/tcp
$ firewall-cmd --permanent --add-port=2379-2380/tcp
$ firewall-cmd --permanent --add-port=10250/tcp
$ firewall-cmd --permanent --add-port=10251/tcp
$ firewall-cmd --permanent --add-port=10252/tcp
$ firewall-cmd --permanent --add-port=10255/tcp
$ firewall-cmd --permanent --add-port=8472/udp
$ firewall-cmd --add-masquerade --permanent

  // only if you want NodePorts exposed on control plane IP as well
$ firewall-cmd --permanent --add-port=30000-32767/tcp

$ systemctl restart firewalld

```

#### Configure firewalld (worker)
```
systemctl start firewalld
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --add-masquerade --permanent

systemctl restart firewalld


```