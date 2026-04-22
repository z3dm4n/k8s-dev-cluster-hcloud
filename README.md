# k8s-dev-cluster-hcloud

Minimal, highly available (HA) Kubernetes cluster on Hetzner Cloud — up and running in under 10 minutes.

Uses **OpenTofu** for cloud infrastructure, **Ansible** for configuration, and **MicroK8s** as the Kubernetes distribution. HA is automatically enabled on MicroK8s clusters with three or more nodes (since 1.19).

## Prerequisites

- [OpenTofu](https://opentofu.org/docs/intro/install/) >= 1.8
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/)
- Hetzner Cloud API token: WebUI → Project → Access → Add API Token

## Setup

```bash
git clone https://github.com/z3dm4n/k8s-dev-cluster-hcloud.git
cd k8s-dev-cluster-hcloud
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# set hcloud_token in terraform/terraform.tfvars
make ssh-key
make
```

## Demo: Install Gitea

```bash
make demo
echo "$(cd terraform; tofu output -raw loadbalancer-ip) www.gitea.local" | sudo tee -a /etc/hosts
```

Browse to [http://www.gitea.local](http://www.gitea.local) and log in with `gitea_admin` / `gitea_admin`.

## Clean Up

```bash
make clean
```

## References

- [MicroK8s High Availability](https://microk8s.io/docs/high-availability)
- [OpenTofu](https://opentofu.org)
