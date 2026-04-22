all: terraform ansible output
.PHONY: all terraform ansible ssh-key output demo clean

terraform:
	cd terraform; \
	tofu init; \
	tofu apply

ansible:
	cd ansible; \
	ansible-playbook site.yml

ssh-key:
	ssh-keygen -f files/k8s-dev-cluster_rsa -C "k8s-dev-cluster project ssh key" -N "" -b 4096

output:
	cd terraform; \
	tofu output

demo:
	cd ansible; \
	ansible-playbook demo/99-setup-microk8s-gitea.yml

clean:
	cd terraform; \
	tofu destroy
