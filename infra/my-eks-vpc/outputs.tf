output "subnet_ids" {
  description = "Subnets IDs in the VPC"
  value       = join(",", [aws_subnet.public_subnet_01.id, aws_subnet.public_subnet_02.id, aws_subnet.private_subnet_01.id, aws_subnet.private_subnet_02.id])
}

output "security_groups" {
  description = "Security group for the cluster control plane communication with worker nodes"
  value       = aws_security_group.control_plane_security_group.id
}

output "vpc_id" {
  description = "The VPC Id"
  value       = aws_vpc.vpc.id
}