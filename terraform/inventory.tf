provider "local" {
  version = "~> 1.4"
}

# generate Ansible inventory file
resource "local_file" "AnsibleInventory" {
  file_permission="0600"

 content = templatefile("inventory.tmpl",
 {
  node1-dns = hcloud_server.n1.name,
  node1-ip = hcloud_server.n1.ipv4_address,
  node1-id = hcloud_server.n1.id,
  node2-dns = hcloud_server.n2.name,
  node2-ip = hcloud_server.n2.ipv4_address,
  node2-id = hcloud_server.n2.id,
  node3-dns = hcloud_server.n3.name,
  node3-ip = hcloud_server.n3.ipv4_address,
  node3-id = hcloud_server.n3.id,
  # node4-dns = hcloud_server.n4.name,
  # node4-ip = hcloud_server.n4.ipv4_address,
  # node4-id = hcloud_server.n4.id,
  # node5-dns = hcloud_server.n5.name,
  # node5-ip = hcloud_server.n5.ipv4_address,
  # node5-id = hcloud_server.n5.id,
  # node6-dns = hcloud_server.n6.name,
  # node6-ip = hcloud_server.n6.ipv4_address,
  # node6-id = hcloud_server.n6.id
 }
 )
 filename = "../ansible/hosts"
}
