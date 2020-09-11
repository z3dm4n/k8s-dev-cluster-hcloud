#
# Basics
#

terraform {
  required_providers {
    hcloud = {
      # Use source on Terraform 0.13 or greater
      # source = "hetznercloud/hcloud"
      # Explicitly use version 1.21.0 of Terraform Hetzner Cloud provider
      version = "1.21.0"
    }
  }
}

# Set the variables values in terraform.tfvars
# or use the -var='hcloud_token="xxx"' CLI option
variable "hcloud_token" {}
variable "private_key_path" {}
variable "public_key_path" {}

provider "hcloud" {
  token = var.hcloud_token
}

# Setup OS image
variable "os_image" {
  type = string
  default = "ubuntu-20.04"
}

# Setup server type
variable "server_type" {
  type = string
  default = "cpx11"
}

# Import SSH key
resource "hcloud_ssh_key" "k8s-dev-cluster" {
  name = "k8s-dev-cluster"
  public_key = file(var.public_key_path)
}

#
# Networking
#

# Setup network
resource "hcloud_network" "vpc1" {
  name = "vpc1"
  ip_range = "10.0.0.0/16"
}

# Setup subnet
resource "hcloud_network_subnet" "vpc1-subnet1" {
  network_id = hcloud_network.vpc1.id
  type = "cloud"
  network_zone = "eu-central"
  ip_range = "10.0.0.0/24"
}

# Setup server networking
resource "hcloud_server_network" "n1-network" {
  server_id = hcloud_server.n1.id
  subnet_id = hcloud_network_subnet.vpc1-subnet1.id
  ip = "10.0.0.2"
}

resource "hcloud_server_network" "n2-network" {
  server_id = hcloud_server.n2.id
  subnet_id = hcloud_network_subnet.vpc1-subnet1.id
  ip = "10.0.0.3"
}

resource "hcloud_server_network" "n3-network" {
  server_id = hcloud_server.n3.id
  subnet_id = hcloud_network_subnet.vpc1-subnet1.id
  ip = "10.0.0.4"
}

#
# Loadbalancing
#

resource "hcloud_load_balancer" "lb1" {
  name = "lb1"
  load_balancer_type = "lb11"
  # network_zone = "eu-central"
  location = "fsn1"
  labels = { role = "loadbalancer" }
  algorithm {
    type = "round_robin"
  }
}

resource "hcloud_load_balancer_network" "lb1-network" {
  load_balancer_id = hcloud_load_balancer.lb1.id
  subnet_id = hcloud_network_subnet.vpc1-subnet1.id
  enable_public_interface = true
  ip = "10.0.0.5"
}

resource "hcloud_load_balancer_target" "lb1-target-n1" {
  type = "server"
  load_balancer_id = hcloud_load_balancer.lb1.id
  server_id = hcloud_server.n1.id
  use_private_ip = true
  depends_on = [
    hcloud_server_network.n1-network,
    hcloud_load_balancer_network.lb1-network
  ]
}

resource "hcloud_load_balancer_target" "lb1-target-n2" {
  type = "server"
  load_balancer_id = hcloud_load_balancer.lb1.id
  server_id = hcloud_server.n2.id
  use_private_ip = true
  depends_on = [
    hcloud_server_network.n2-network,
    hcloud_load_balancer_network.lb1-network
  ]
}

resource "hcloud_load_balancer_target" "lb1-target-n3" {
  type = "server"
  load_balancer_id = hcloud_load_balancer.lb1.id
  server_id = hcloud_server.n3.id
  use_private_ip = true
  depends_on = [
    hcloud_server_network.n3-network,
    hcloud_load_balancer_network.lb1-network
  ]
}

resource "hcloud_load_balancer_service" "lb1-service" {
  load_balancer_id = hcloud_load_balancer.lb1.id
  protocol = "http"
  listen_port = 80
  destination_port = 80
  health_check {
    protocol = "http"
    port = 80
    interval = 15
    timeout = 10
    http {
      domain = "www.gitea.local"
    }
  }
}

#
# Servers
#

# node1
resource "hcloud_server" "n1" {
  name = "n1"
  image = var.os_image
  server_type = var.server_type
  location = "fsn1" # possible values: fsn1,nbg1,hel1
  ssh_keys = [ hcloud_ssh_key.k8s-dev-cluster.id ]
  labels = { role = "node" }
  # wait for the VM to spin up
  provisioner "remote-exec" {
    inline = [ "/bin/true" ]
    connection {
      type = "ssh"
      user = "root"
      host = hcloud_server.n1.ipv4_address
      private_key = file(var.private_key_path)
    }
}
}

# node2
resource "hcloud_server" "n2" {
  name = "n2"
  image = var.os_image
  server_type = var.server_type
  location = "fsn1"
  ssh_keys = [ hcloud_ssh_key.k8s-dev-cluster.id ]
  labels = { role = "node" }
  # wait for the VM to spin up
  provisioner "remote-exec" {
    inline = [ "/bin/true" ]
    connection {
      type = "ssh"
      user = "root"
      host = hcloud_server.n2.ipv4_address
      private_key = file(var.private_key_path)
    }
}
}

# node3
resource "hcloud_server" "n3" {
  name = "n3"
  image = var.os_image
  server_type = var.server_type
  location = "fsn1"
  ssh_keys = [ hcloud_ssh_key.k8s-dev-cluster.id ]
  labels = { role = "node" }
  # wait for the VM to spin up
  provisioner "remote-exec" {
    inline = [ "/bin/true" ]
    connection {
      type = "ssh"
      user = "root"
      host = hcloud_server.n3.ipv4_address
      private_key = file(var.private_key_path)
    }
}
}
