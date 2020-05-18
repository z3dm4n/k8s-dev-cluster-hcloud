provider "local" {
  version = "~> 1.4"
}

# generate Ansible inventory file
resource "local_file" "AnsibleInventory" {
  file_permission="0600"

 content = templatefile("inventory.tmpl",
 {
  master-dns = hcloud_server.m.name,
  master-ip = hcloud_server.m.ipv4_address,
  master-id = hcloud_server.m.id,
  worker1-dns = hcloud_server.n1.name,
  worker1-ip = hcloud_server.n1.ipv4_address,
  worker1-id = hcloud_server.n1.id,
  worker2-dns = hcloud_server.n2.name,
  worker2-ip = hcloud_server.n2.ipv4_address,
  worker2-id = hcloud_server.n2.id
 }
 )
 filename = "../ansible/hosts"
}
