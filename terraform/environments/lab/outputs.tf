output "control_plane_instance_id" {
  description = "ID of the lab EC2 instance."
  value       = aws_instance.lab_node_control_plane.id
}

output "control_plane_public_ip" {
  description = "Public IPv4 address used to connect to the lab instance."
  value       = aws_instance.lab_node_control_plane.public_ip
}

output "control_plane_private_ip" {
  description = "Private IPv4 address of the lab instance."
  value       = aws_instance.lab_node_control_plane.private_ip
}
output "worker_1_instance_id" {
  description = "ID of the lab worker EC2 instance 1."
  value       = aws_instance.lab-node-worker-1.id
}
output "worker_1_public_ip" {
  description = "Public IPv4 address used to connect to the lab worker instance 1."
  value       = aws_instance.lab-node-worker-1.public_ip
}
output "worker_1_private_ip" {
  description = "Private IPv4 address of the lab worker instance 1."
  value       = aws_instance.lab-node-worker-1.private_ip
}
output "worker_2_instance_id" {
  description = "ID of the lab worker EC2 instance 2."
  value       = aws_instance.lab-node-worker-2.id
}
output "worker_2_public_ip" {
  description = "Public IPv4 address used to connect to the lab worker instance 2."
  value       = aws_instance.lab-node-worker-2.public_ip
}
output "worker_2_private_ip" {
  description = "Private IPv4 address of the lab worker instance 2."
  value       = aws_instance.lab-node-worker-2.private_ip
}
output "vpc_id" {
  description = "ID of the dedicated lab VPC."
  value       = module.network.vpc_id
}

output "ha_proxy_instance_id" {
  description = "ID of the HAProxy frontend instance."
  value       = module.ha_proxy.instance_id
}

output "ha_proxy_public_ip" {
  description = "Public IPv4 address of the HAProxy frontend."
  value       = module.ha_proxy.public_ip
}

output "ha_proxy_private_ip" {
  description = "Private IPv4 address of the HAProxy frontend."
  value       = module.ha_proxy.private_ip
}

output "ha_proxy_public_dns" {
  description = "Public DNS name of the HAProxy frontend."
  value       = module.ha_proxy.public_dns
}
