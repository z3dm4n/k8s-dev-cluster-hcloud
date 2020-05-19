# Notes

## Install a simple test app to your cluster

```bash
root@m1:~$ alias k='microk8s.kubectl'
# add floating IP to m1 via WebUI -> TODO: automate with terraform + ansible
root@m1:~$ ip addr add 49.12.114.XXX dev eth0
# enable MetalLB loadbalancer
root@m1:~$ microk8s.enable metallb
Enabling MetalLB
Enter the IP address range (e.g., 10.64.140.43-10.64.140.49): 49.12.114.XXX-49.12.114.XXX
# use Helm
root@m1:~$ microk8s.enable helm3
root@m1:~$ alias helm='microk8s.helm3'
root@m1:~$ helm repo add bitnami https://charts.bitnami.com/bitnami
# install Helm Chart for testing purposes
root@m1:~$ helm install test bitnami/nginx \
--set='replicaCount=3' \
--set='cloneStaticSiteFromGit.enabled=true' \
--set='cloneStaticSiteFromGit.repository="https://gist.github.com/d395ce9d32321b57e5844dcdcfc0acb7.git"' \
--set='cloneStaticSiteFromGit.branch="master"'
root@m1:~$ k get pods -owide
NAME                          READY   STATUS    RESTARTS   AGE   IP          NODE       NOMINATED NODE   READINESS GATES
test-nginx-84f7d6bb98-8lhc2   0/1     Running   0          2s    10.1.70.7   10.0.0.4   <none>           <none>
test-nginx-84f7d6bb98-95bdq   0/1     Running   0          2s    10.1.87.6   m1         <none>           <none>
test-nginx-84f7d6bb98-vfpp6   0/1     Running   0          2s    10.1.44.7   10.0.0.3   <none>           <none>
root@m1:~$ k get svc
NAME         TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
kubernetes   ClusterIP      10.152.183.1     <none>          443/TCP                      67m
test-nginx   LoadBalancer   10.152.183.192   49.12.114.XXX   80:31754/TCP,443:32723/TCP   16m
# see if it works using `curl`
local$ curl http://49.12.114.XXX/
```

You just installed a simple test deployment to your new MicroK8s cluster and
accessed it via an external LoadBalancer IP. Voilà.
