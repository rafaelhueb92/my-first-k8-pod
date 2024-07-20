variable "vpc_block" {
  default     = "192.168.0.0/16"
  description = "The CIDR range for the VPC. This should be a valid private (RFC 1918) CIDR range."
}

variable "public_subnet_01_block" {
  default     = "192.168.0.0/18"
  description = "CidrBlock for public subnet 01 within the VPC"
}

variable "public_subnet_02_block" {
  default     = "192.168.64.0/18"
  description = "CidrBlock for public subnet 02 within the VPC"
}

variable "private_subnet_01_block" {
  default     = "192.168.128.0/18"
  description = "CidrBlock for private subnet 01 within the VPC"
}

variable "private_subnet_02_block" {
  default     = "192.168.192.0/18"
  description = "CidrBlock for private subnet 02 within the VPC"
}

variable "aws_stack_name" {
  default     = "eks-stack-vpc"
  description = "Stack default name"
}
