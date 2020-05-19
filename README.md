# k8s-dev-cluster-hcloud

Build a minimal Kubernetes cluster with zero effort in less than 10 minutes in
Hetzner Cloud aka hcloud with MicroK8s

## get hcloud API Token

hcloud WebUI -> Create new project -> Enter new project -> Access -> Add API Token

## clone repo

```bash
$ git clone https://github.com/z3dm4n/k8s-dev-cluster-hcloud.git ~/k8s-dev-cluster-hcloud
$ cd ~/k8s-dev-cluster-hcloud
$ cp terraform/terraform.tfvars.example terraform/terraform.tfvars
$ # change hcloud_token in terraform/terraform.tfvars
```

## create ssh key

```bash
$ make ssh-key
```

## run terraform + ansible

```bash
$ make
```

## setup microk8s cluster (copy&paste)

```bash
$ ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no \
-i files/k8s-dev-cluster_rsa root@$SeeInventoryForIpAddresses
root@m1:~$ microk8s.add-node
root@n1:~$ microk8s join
root@m1:~$ microk8s.add-node
root@n2:~$ microk8s join
root@m1:~$ alias k='microk8s.kubectl'
root@m1:~$ k get nodes
NAME       STATUS   ROLES    AGE     VERSION
10.0.0.3   Ready    <none>   4m30s   v1.18.2-41+b5cdb79a4060a3
10.0.0.4   Ready    <none>   91s     v1.18.2-41+b5cdb79a4060a3
m1         Ready    <none>   9m4s    v1.18.2-41+b5cdb79a4060a3
```

Find out more: https://microk8s.io

# clean up, safe money ;-)

```bash
$ make clean
```
