output "server-ips" {
  value = [
    hcloud_server.n1.ipv4_address,
    hcloud_server.n2.ipv4_address,
    hcloud_server.n3.ipv4_address,
    hcloud_server.n4.ipv4_address,
    hcloud_server.n5.ipv4_address,
    hcloud_server.n6.ipv4_address
  ]
}

output "loadbalancer-ip" {
  value = hcloud_load_balancer.lb1.ipv4
}
