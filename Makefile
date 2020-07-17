all: terraform ansible output
.PHONY: all terraform ansible ssh-key output clean

terraform:
	cd terraform; \
	terraform init; \
	terraform apply

ansible:
	cd ansible; \
	ansible-playbook site.yml

ssh-key:
	ssh-keygen -f files/k8s-dev-cluster_rsa -C "k8s-dev-cluster project ssh key" -N "" -b 4096

output:
	cd terraform; \
	terraform output

clean:
	cd terraform; \
	terraform destroy
