#
# Basics
#

# Set the variables values in terraform.tfvars
# or use the -var='hcloud_token="xxx"' CLI option
variable "hcloud_token" {}
variable "private_key_path" {}
variable "public_key_path" {}

# Setup OS image
variable "os_image" {
  type = string
  default = "ubuntu-20.04"
}

# Setup server type
variable "server_type" {
  type = string
  default = "cx21"
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
  version = "~> 1.18"
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
  network_id = hcloud_network.vpc1.id
  ip = "10.0.0.2"
}

resource "hcloud_server_network" "n2-network" {
  server_id = hcloud_server.n2.id
  network_id = hcloud_network.vpc1.id
  ip = "10.0.0.3"
}

resource "hcloud_server_network" "n3-network" {
  server_id = hcloud_server.n3.id
  network_id = hcloud_network.vpc1.id
  ip = "10.0.0.4"
}

# resource "hcloud_server_network" "n4-network" {
#   server_id = hcloud_server.n4.id
#   network_id = hcloud_network.vpc1.id
#   ip = "10.0.0.5"
# }

# resource "hcloud_server_network" "n5-network" {
#   server_id = hcloud_server.n5.id
#   network_id = hcloud_network.vpc1.id
#   ip = "10.0.0.6"
# }

# resource "hcloud_server_network" "n6-network" {
#   server_id = hcloud_server.n6.id
#   network_id = hcloud_network.vpc1.id
#   ip = "10.0.0.7"
# }

#
# Loadbalancing
#

resource "hcloud_load_balancer" "lb1" {
  name = "lb1"
  load_balancer_type = "lb11"
  # network_zone = "eu-central"
  location = "nbg1"
  labels = { role = "loadbalancer" }
  algorithm {
    type = "round_robin"
  }
}

resource "hcloud_load_balancer_network" "lb1-network" {
  load_balancer_id = hcloud_load_balancer.lb1.id
  network_id = hcloud_network.vpc1.id
  enable_public_interface = true
  ip = "10.0.0.8"
}

resource "hcloud_load_balancer_target" "lb1-target-n1" {
  type = "server"
  load_balancer_id = hcloud_load_balancer.lb1.id
  server_id = hcloud_server.n1.id
  use_private_ip = true
  depends_on = [
    hcloud_server.n1,
    hcloud_server_network.n1-network
  ]
}

resource "hcloud_load_balancer_target" "lb1-target-n2" {
  type = "server"
  load_balancer_id = hcloud_load_balancer.lb1.id
  server_id = hcloud_server.n2.id
  use_private_ip = true
  depends_on = [
    hcloud_server.n2,
    hcloud_server_network.n2-network
  ]
}

resource "hcloud_load_balancer_target" "lb1-target-n3" {
  type = "server"
  load_balancer_id = hcloud_load_balancer.lb1.id
  server_id = hcloud_server.n3.id
  use_private_ip = true
  depends_on = [
    hcloud_server.n3,
    hcloud_server_network.n3-network
  ]
}

# resource "hcloud_load_balancer_target" "lb1-target-n4" {
#   type = "server"
#   load_balancer_id = hcloud_load_balancer.lb1.id
#   server_id = hcloud_server.n4.id
#   use_private_ip = true
#   depends_on = [
#     hcloud_server.n4,
#     hcloud_server_network.n4-network
#   ]
# }

# resource "hcloud_load_balancer_target" "lb1-target-n5" {
#   type = "server"
#   load_balancer_id = hcloud_load_balancer.lb1.id
#   server_id = hcloud_server.n5.id
#   use_private_ip = true
#   depends_on = [
#     hcloud_server.n5,
#     hcloud_server_network.n5-network
#   ]
# }

# resource "hcloud_load_balancer_target" "lb1-target-n6" {
#   type = "server"
#   load_balancer_id = hcloud_load_balancer.lb1.id
#   server_id = hcloud_server.n6.id
#   use_private_ip = true
#   depends_on = [
#     hcloud_server.n6,
#     hcloud_server_network.n6-network
#   ]
# }

resource "hcloud_load_balancer_service" "lb1-service" {
  load_balancer_id = hcloud_load_balancer.lb1.id
  protocol = "http"
  listen_port = 80
  destination_port = 30007
  health_check {
    protocol = "http"
    port = 30007
    interval = 15
    timeout = 10
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
  location = "nbg1"
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
  location = "hel1"
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

# # node4
# resource "hcloud_server" "n4" {
#   name = "n4"
#   image = var.os_image
#   server_type = var.server_type
#   location = "nbg1" # possible values: fsn1,nbg1,hel1
#   ssh_keys = [ hcloud_ssh_key.k8s-dev-cluster.id ]
#   labels = { role = "node" }
#   # wait for the VM to spin up
#   provisioner "remote-exec" {
#     inline = [ "/bin/true" ]
#     connection {
#       type = "ssh"
#       user = "root"
#       host = hcloud_server.n4.ipv4_address
#       private_key = file(var.private_key_path)
#     }
# }
# }

# # node5
# resource "hcloud_server" "n5" {
#   name = "n5"
#   image = var.os_image
#   server_type = var.server_type
#   location = "nbg1"
#   ssh_keys = [ hcloud_ssh_key.k8s-dev-cluster.id ]
#   labels = { role = "node" }
#   # wait for the VM to spin up
#   provisioner "remote-exec" {
#     inline = [ "/bin/true" ]
#     connection {
#       type = "ssh"
#       user = "root"
#       host = hcloud_server.n5.ipv4_address
#       private_key = file(var.private_key_path)
#     }
# }
# }

# # node6
# resource "hcloud_server" "n6" {
#   name = "n6"
#   image = var.os_image
#   server_type = var.server_type
#   location = "nbg1"
#   ssh_keys = [ hcloud_ssh_key.k8s-dev-cluster.id ]
#   labels = { role = "node" }
#   # wait for the VM to spin up
#   provisioner "remote-exec" {
#     inline = [ "/bin/true" ]
#     connection {
#       type = "ssh"
#       user = "root"
#       host = hcloud_server.n6.ipv4_address
#       private_key = file(var.private_key_path)
#     }
# }
# }
