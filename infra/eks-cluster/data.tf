data "aws_ssm_parameter" "eks_role_arn" {
  name = "/eks/role/arn"
}

data "aws_ssm_parameter" "ec2_role_arn" {
  name = "/ec2/role/arn"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

data "aws_ssm_parameter" "subnet_ids" {
  name = "/vpc/subnet_ids"
}

data "aws_ssm_parameter" "security_group_id" {
  name = "/vpc/security_group_id"
}