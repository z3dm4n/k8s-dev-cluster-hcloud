# k8s-dev-cluster-hcloud

Build a minimal Kubernetes cluster with zero effort in less than 10 minutes in
Hetzner Cloud aka hcloud with Terraform, Ansible and MicroK8s for development

## get hcloud API Token

hcloud WebUI -> Create new project -> Enter new project -> Access -> Add API Token

## clone repo

```bash
local$ git clone https://github.com/z3dm4n/k8s-dev-cluster-hcloud.git k8s-dev-cluster-hcloud
local$ cd k8s-dev-cluster-hcloud
local$ git checkout master
local$ cp terraform/terraform.tfvars.example terraform/terraform.tfvars
local$ # change hcloud_token in terraform/terraform.tfvars
```

## create ssh key

```bash
local$ make ssh-key
```

## run terraform + ansible

```bash
local$ make
```

## demo: install Gitea to your cluster

```bash
local$ make demo
local$ cd terraform; echo "`terraform output loadbalancer-ip` www.gitea.local"
local$ # add above command output to /etc/hosts
```

Now browse to http://www.gitea.local and finish the Gitea installation.

## summary

You just installed Gitea to your new MicroK8s cluster in less than 10 minutes.

Learn more: https://microk8s.io/docs/clustering

## clean up, save money ;-)

```bash
local$ make clean
```
