output "eks_role_arn" {
  value = aws_iam_role.eks_role.arn
  description = "The ARN of the EKS role"
}

output "ec2_role_arn" {
  value       = aws_iam_role.ec2_role.arn
  description = "The ARN of the EC2 role for EKS Worker Nodes"
}