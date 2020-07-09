# k8s-dev-cluster-hcloud (HA preview)

**!!! HA for MicroK8s is currently only available as a tech preview for testing
purposes. !!!**

Build a minimal Kubernetes HA cluster with zero effort in less than 10 minutes in
Hetzner Cloud aka hcloud with Terraform, Ansible and MicroK8s for development

## get hcloud API Token

hcloud WebUI -> Create new project -> Enter new project -> Access -> Add API Token

## clone repo

```bash
local$ git clone https://github.com/z3dm4n/k8s-dev-cluster-hcloud.git k8s-dev-cluster-hcloud
local$ cd k8s-dev-cluster-hcloud
local$ git checkout ha-preview
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

## setup microk8s HA cluster (copy&paste)

```bash
local$ ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no \
-i files/k8s-dev-cluster_rsa root@$Server-IP
n1$ microk8s.add-node
n2$ microk8s join 10.0.0.2:25000/XXX
Waiting for node to join the cluster. ..
n1$ microk8s.add-node
n3$ microk8s join 10.0.0.2:25000/XXX
Waiting for node to join the cluster. ..
n1$ k get nodes
NAME   STATUS   ROLES    AGE     VERSION
n1     Ready    <none>   7m10s   v1.18.5-33+2b6eed5dfebf7c
n2     Ready    <none>   2m17s   v1.18.5-33+2b6eed5dfebf7c
n3     Ready    <none>   31s     v1.18.5-33+2b6eed5dfebf7c
n1$ microk8s status
microk8s is running
high-availability: yes
  datastore master nodes: 10.0.0.2:19001 10.0.0.3:19001 10.0.0.4:19001
  datastore standby nodes: none
```

## install a simple test app to your cluster

```bash
# enable MetalLB loadbalancer
# assign loadbalancer-ip (see `terraform output loadbalancer-ip` or `make output`)
m1$ microk8s.enable metallb
Enabling MetalLB
Enter the IP address range (e.g., 10.64.140.43-10.64.140.49): xxx.xxx.xxx.xxx-xxx.xxx.xxx.xxx
# use Helm
m1$ helm repo add bitnami https://charts.bitnami.com/bitnami
# install Helm Chart for testing purposes
m1$ helm install test bitnami/nginx \
--set='service.nodePorts.http=30007' \
--set='replicaCount=3' \
--set='cloneStaticSiteFromGit.enabled=true' \
--set='cloneStaticSiteFromGit.repository="https://gist.github.com/d395ce9d32321b57e5844dcdcfc0acb7.git"' \
--set='cloneStaticSiteFromGit.branch="master"'
m1$ k get pods -owide
NAME                         READY   STATUS    RESTARTS   AGE     IP            NODE   NOMINATED NODE   READINESS GATES
test-nginx-58fbb6897-bkdkn   2/2     Running   0          5m19s   10.1.217.1    n2     <none>           <none>
test-nginx-58fbb6897-rmwwr   2/2     Running   0          5m19s   10.1.40.132   n1     <none>           <none>
test-nginx-58fbb6897-8zg72   2/2     Running   0          5m19s   10.1.98.1     n3     <none>           <none>
m1$ k get svc
NAME         TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                      AGE
kubernetes   ClusterIP      10.152.183.1     <none>           443/TCP                      92m
test-nginx   LoadBalancer   10.152.183.205   xxx.xxx.xxx.xxx  80:30007/TCP,443:32581/TCP   84s
# see if it works using `curl` or just use your favourite browser
local$ curl http://xxx.xxx.xxx.xxx/
```

You just installed a simple test deployment to your new highly-available MicroK8s
cluster and accessed it via an external LoadBalancer IP.

Learn more: https://microk8s.io/docs/high-availability

## clean up, save money ;-)

```bash
local$ make clean
```
