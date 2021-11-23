provider "local" {
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
  loadbalancer-ip = hcloud_load_balancer.lb1.ipv4
 }
 )
 filename = "../ansible/inventory/hosts"
}
