output "vpc_id" {
  description = "ID of the dedicated lab VPC."
  value       = aws_vpc.lab.id
}

output "public_subnet_id" {
  description = "ID of the lab's public subnet."
  value       = aws_subnet.lab_public.id
  depends_on  = [aws_route_table_association.lab_public]
}

output "security_group_id" {
  description = "ID of the SSH-restricted lab security group."
  value       = aws_security_group.lab.id
}
