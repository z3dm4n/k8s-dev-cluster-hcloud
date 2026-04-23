all: terraform ansible output
.PHONY: all terraform ansible ssh-key output demo clean

terraform:
	cd terraform && \
	tofu init && \
	tofu apply

ansible:
	cd ansible && \
	ansible-playbook site.yml

ssh-key:
	ssh-keygen -t ed25519 -f files/k8s-dev-cluster -C "k8s-dev-cluster project ssh key" -N ""

output:
	cd terraform && \
	tofu output

demo:
	cd ansible && \
	ansible-playbook demo/99-setup-microk8s-gitea.yml --ask-vault-pass

clean:
	cd terraform && \
	tofu destroy
