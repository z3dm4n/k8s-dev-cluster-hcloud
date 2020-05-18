# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {}
variable "private_key_path" {}
variable "public_key_fingerprint" {}
variable "public_key_path" {}

variable "os_image" {
  type = string
  default = "ubuntu-20.04"
}

variable "server_type" {
  type = string
  default = "cx11"
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
  version = "~> 1.16"
}

# Create a new SSH key
resource "hcloud_ssh_key" "k8s-dev-cluster" {
  name = "k8s-dev-cluster"
  public_key = file(var.public_key_path)
}

# Network Setup
resource "hcloud_network" "vpc1" {
  name = "vpc1"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "vpc1-subnet1" {
  network_id = hcloud_network.vpc1.id
  type = "server"
  network_zone = "eu-central"
  ip_range = "10.0.0.0/24"
}

resource "hcloud_server_network" "m-network" {
  server_id = hcloud_server.m.id
  network_id = hcloud_network.vpc1.id
  ip = "10.0.0.2"
}

resource "hcloud_server_network" "n1-network" {
  server_id = hcloud_server.n1.id
  network_id = hcloud_network.vpc1.id
  ip = "10.0.0.3"
}

resource "hcloud_server_network" "n2-network" {
  server_id = hcloud_server.n2.id
  network_id = hcloud_network.vpc1.id
  ip = "10.0.0.4"
}

# Create VMs

# master
resource "hcloud_server" "m" {
  name = "m"
  image = var.os_image
  server_type = var.server_type
  location = "fsn1" # fsn1,nbg1,hel1
  ssh_keys = [ hcloud_ssh_key.k8s-dev-cluster.id ]
  labels = { role = "k8s-master" }

  provisioner "remote-exec" {
    inline = [ "apt-get -qq install python3 -y" ]

    connection {
      type = "ssh"
      user = "root"
      host = hcloud_server.m.ipv4_address
      private_key = file(var.private_key_path)
    }
}
}

# node1
resource "hcloud_server" "n1" {
  name = "n1"
  image = var.os_image
  server_type = var.server_type
  location = "fsn1" # fsn1,nbg1,hel1
  ssh_keys = [ hcloud_ssh_key.k8s-dev-cluster.id ]
  labels = { role = "k8s-worker" }

  provisioner "remote-exec" {
    inline = [ "apt-get -qq install python3 -y" ]

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
  location = "nbg1" # fsn1,nbg1,hel1
  ssh_keys = [ hcloud_ssh_key.k8s-dev-cluster.id ]
  labels = { role = "k8s-worker" }

  provisioner "remote-exec" {
    inline = [ "apt-get -qq install python3 -y" ]

    connection {
      type = "ssh"
      user = "root"
      host = hcloud_server.n2.ipv4_address
      private_key = file(var.private_key_path)
    }
}
}
