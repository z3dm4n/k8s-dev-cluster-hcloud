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

## setup microk8s cluster (copy&paste)

```bash
local$ ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no \
-i files/k8s-dev-cluster_rsa root@$Server-IP
n1$ microk8s.add-node
n2$ microk8s join 10.0.0.2:25000/XXX
n1$ microk8s.add-node
n3$ microk8s join 10.0.0.2:25000/XXX
n1$ k get nodes
NAME       STATUS   ROLES    AGE   VERSION
10.0.0.3   Ready    <none>   67s   v1.18.4-1+6f17be3f1fd54a
10.0.0.4   Ready    <none>   28s   v1.18.4-1+6f17be3f1fd54a
n1         Ready    <none>   14m   v1.18.4-1+6f17be3f1fd54a
```

## install a simple test app to your cluster

```bash
# use Helm
n1$ helm repo add bitnami https://charts.bitnami.com/bitnami
# install Helm Chart for testing purposes
n1$ helm install test bitnami/nginx \
--set='service.type=NodePort' \
--set='service.nodePorts.http=30007' \
--set='replicaCount=3' \
--set='cloneStaticSiteFromGit.enabled=true' \
--set='cloneStaticSiteFromGit.repository="https://gist.github.com/d395ce9d32321b57e5844dcdcfc0acb7.git"' \
--set='cloneStaticSiteFromGit.branch="master"'
n1$ k get pods -owide
NAME                         READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
test-nginx-58fbb6897-c5cjk   2/2     Running   0          14s   10.1.17.6    10.0.0.3   <none>           <none>
test-nginx-58fbb6897-dsgt4   2/2     Running   0          14s   10.1.53.11   n1         <none>           <none>
test-nginx-58fbb6897-nwvhl   2/2     Running   0          14s   10.1.13.6    10.0.0.4   <none>           <none>
n1$ k get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
kubernetes   ClusterIP   10.152.183.1    <none>        443/TCP                      22m
test-nginx   NodePort    10.152.183.67   <none>        80:30007/TCP,443:30602/TCP   8m13s
# see if it works using `curl` or just use your favourite browser
local$ cd terraform
local$ curl http://`terraform output loadbalancer-ip`
```

You just installed a simple test deployment to your new MicroK8s cluster and
accessed its service using Hetzners new load balancing feature.

Learn more: https://microk8s.io/docs/clustering

## clean up, save money ;-)

```bash
local$ make clean
```
