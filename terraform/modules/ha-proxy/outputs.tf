output "instance_id" {
  description = "ID of the HAProxy EC2 instance."
  value       = aws_instance.proxy.id
}

output "public_ip" {
  description = "Public IPv4 address of the HAProxy instance."
  value       = aws_instance.proxy.public_ip
}

output "private_ip" {
  description = "Private IPv4 address of the HAProxy instance."
  value       = aws_instance.proxy.private_ip
}

output "public_dns" {
  description = "Public DNS name of the HAProxy instance."
  value       = aws_instance.proxy.public_dns
}
