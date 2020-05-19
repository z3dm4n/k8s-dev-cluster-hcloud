# k8s-dev-cluster-hcloud

Build a minimal Kubernetes cluster with zero effort in less than 10 minutes in
Hetzner Cloud aka hcloud with MicroK8s

## get hcloud API Token

hcloud WebUI -> Create new project -> Enter new project -> Access -> Add API Token

## clone repo

```bash
local$ git clone https://github.com/z3dm4n/k8s-dev-cluster-hcloud.git ~/k8s-dev-cluster-hcloud
local$ cd ~/k8s-dev-cluster-hcloud
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
-i files/k8s-dev-cluster_rsa root@$SeeInventoryForIpAddresses
m1$ microk8s.add-node
n1$ microk8s join
m1$ microk8s.add-node
n2$ microk8s join
m1$ k get nodes
NAME       STATUS   ROLES    AGE     VERSION
10.0.0.3   Ready    <none>   4m30s   v1.18.2-41+b5cdb79a4060a3
10.0.0.4   Ready    <none>   91s     v1.18.2-41+b5cdb79a4060a3
m1         Ready    <none>   9m4s    v1.18.2-41+b5cdb79a4060a3
```

## install a simple test app to your cluster

```bash
# enable MetalLB loadbalancer
m1$ microk8s.enable metallb
Enabling MetalLB
Enter the IP address range (e.g., 10.64.140.43-10.64.140.49): 49.12.114.XXX-49.12.114.XXX
# use Helm
m1$ helm repo add bitnami https://charts.bitnami.com/bitnami
# install Helm Chart for testing purposes
m1$ helm install test bitnami/nginx \
--set='replicaCount=3' \
--set='cloneStaticSiteFromGit.enabled=true' \
--set='cloneStaticSiteFromGit.repository="https://gist.github.com/d395ce9d32321b57e5844dcdcfc0acb7.git"' \
--set='cloneStaticSiteFromGit.branch="master"'
m1$ k get pods -owide
NAME                          READY   STATUS    RESTARTS   AGE   IP          NODE       NOMINATED NODE   READINESS GATES
test-nginx-84f7d6bb98-8lhc2   0/1     Running   0          2s    10.1.70.7   10.0.0.4   <none>           <none>
test-nginx-84f7d6bb98-95bdq   0/1     Running   0          2s    10.1.87.6   m1         <none>           <none>
test-nginx-84f7d6bb98-vfpp6   0/1     Running   0          2s    10.1.44.7   10.0.0.3   <none>           <none>
m1$ k get svc
NAME         TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
kubernetes   ClusterIP      10.152.183.1     <none>          443/TCP                      67m
test-nginx   LoadBalancer   10.152.183.192   49.12.114.XXX   80:31754/TCP,443:32723/TCP   16m
# see if it works using `curl`
local$ curl http://49.12.114.XXX/
```

You just installed a simple test deployment to your new MicroK8s cluster and
accessed it via an external LoadBalancer IP. Voilà.

Find out more: https://microk8s.io

## clean up, save money ;-)

```bash
local$ make clean
```
