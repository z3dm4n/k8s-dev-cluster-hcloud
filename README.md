# k8s-dev-cluster-hcloud

## hcloud API Token

hcloud WebUI -> Create new project -> Enter new project -> Access -> Add API Token

## git clone

```bash
git clone https://github.com/z3dm4n/k8s-dev-cluster-hcloud.git ~/k8s-dev-cluster-hcloud
```

## ssh-keygen

```bash
$ cd ~/k8s-dev-cluster-hcloud
$ ssh-keygen -f files/k8s-dev-cluster_rsa -C "k8s-dev-cluster project ssh key" \
-N "" -b 4096
```

## terraform

```bash
$ cd terraform
$ terraform init
$ terraform plan
$ terraform apply
$ terraform destroy
```

## ansible

```bash
$ cd ansible
$ ansible-playbook site.yml
```

## microk8s

```bash
root@m:~# microk8s.add-node
root@n1:~# microk8s join
root@m:~# microk8s.add-node
root@n2:~# microk8s join
root@m:~# microk8s.kubectl get nodes
root@m:~# alias k='microk8s.kubectl'
root@m:~# k get nodes
NAME       STATUS   ROLES    AGE     VERSION
10.0.0.3   Ready    <none>   4m30s   v1.18.2-41+b5cdb79a4060a3
10.0.0.4   Ready    <none>   91s     v1.18.2-41+b5cdb79a4060a3
m          Ready    <none>   9m4s    v1.18.2-41+b5cdb79a4060a3
```
