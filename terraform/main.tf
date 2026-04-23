#
# Basics
#

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.57.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 1.4"
    }
  }
  required_version = ">= 0.13"
}

# Set the variable values in terraform.tfvars
# or use the -var='hcloud_token="xxx"' CLI option
variable "hcloud_token" {}
variable "private_key_path" {}
variable "public_key_path" {}

variable "os_image" {
  type    = string
  default = "ubuntu-24.04"
}

variable "server_type" {
  type    = string
  default = "cx23"
}

variable "location" {
  type        = string
  default     = "fsn1"
  description = "Hetzner Cloud location (fsn1, nbg1, hel1)"
}

variable "lb_type" {
  type    = string
  default = "lb11"
}

variable "network_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "node_private_ips" {
  type = map(string)
  default = {
    n1 = "10.0.0.2"
    n2 = "10.0.0.3"
    n3 = "10.0.0.4"
  }
}

variable "lb_private_ip" {
  type    = string
  default = "10.0.0.5"
}

provider "hcloud" {
  token = var.hcloud_token
}

locals {
  nodes = var.node_private_ips
}

# Import SSH key
resource "hcloud_ssh_key" "k8s-dev-cluster" {
  name       = "k8s-dev-cluster"
  public_key = trimspace(file(var.public_key_path))
}

#
# Networking
#

resource "hcloud_network" "vpc1" {
  name     = "vpc1"
  ip_range = var.network_cidr
}

resource "hcloud_network_subnet" "vpc1-subnet1" {
  network_id   = hcloud_network.vpc1.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = var.subnet_cidr
}

resource "hcloud_server_network" "nodes" {
  for_each  = local.nodes
  server_id = hcloud_server.nodes[each.key].id
  subnet_id = hcloud_network_subnet.vpc1-subnet1.id
  ip        = each.value
}

#
# Loadbalancing
#

resource "hcloud_load_balancer" "lb1" {
  name               = "lb1"
  load_balancer_type = var.lb_type
  location           = var.location
  labels             = { role = "loadbalancer" }
  algorithm {
    type = "round_robin"
  }
}

resource "hcloud_load_balancer_network" "lb1-network" {
  load_balancer_id        = hcloud_load_balancer.lb1.id
  subnet_id               = hcloud_network_subnet.vpc1-subnet1.id
  enable_public_interface = true
  ip                      = var.lb_private_ip
}

resource "hcloud_load_balancer_target" "nodes" {
  for_each         = local.nodes
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb1.id
  server_id        = hcloud_server.nodes[each.key].id
  use_private_ip   = true
  depends_on = [
    hcloud_server_network.nodes,
    hcloud_load_balancer_network.lb1-network
  ]
}

resource "hcloud_load_balancer_service" "lb1-service" {
  load_balancer_id = hcloud_load_balancer.lb1.id
  protocol         = "http"
  listen_port      = 80
  destination_port = 80
  health_check {
    protocol = "tcp"
    port     = 80
    interval = 15
    timeout  = 10
    retries  = 3
  }
}

#
# Servers
#

resource "hcloud_server" "nodes" {
  for_each    = local.nodes
  name        = each.key
  image       = var.os_image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.k8s-dev-cluster.id]
  labels      = { role = "node" }

  provisioner "remote-exec" {
    inline = ["/bin/true"]
    connection {
      type        = "ssh"
      user        = "root"
      host        = self.ipv4_address
      private_key = file(var.private_key_path)
    }
  }
}
