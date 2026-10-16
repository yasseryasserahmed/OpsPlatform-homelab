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

output "vpc_id" {
  description = "ID of the dedicated lab VPC."
  value       = module.network.vpc_id
}
