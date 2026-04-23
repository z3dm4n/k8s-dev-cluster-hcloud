output "server-ips" {
  value = { for k, v in hcloud_server.nodes : k => v.ipv4_address }
}

output "loadbalancer-ip" {
  value = hcloud_load_balancer.lb1.ipv4
}
