resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks-aplicativo-votos"
  role_arn = data.aws_ssm_parameter.eks_role_arn.value

  vpc_config {
    subnet_ids         = split(",", data.aws_ssm_parameter.subnet_ids.value)
    security_group_ids = [data.aws_ssm_parameter.security_group_id.value]
  }

  tags = {
    created_by_me = "TRUE"
  }
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-group-node"
  node_role_arn   = data.aws_ssm_parameter.ec2_role_arn.value
  subnet_ids      = split(",", data.aws_ssm_parameter.subnet_ids.value)

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t2.micro"]
  disk_size     = 20

  remote_access {
    ec2_ssh_key = aws_key_pair.eks_key_pair.key_name
  }

  tags = {
    created_by_me = "TRUE"
  }
}

resource "aws_key_pair" "eks_key_pair" {
  key_name   = "eks_key_pair"
  public_key = file(var.ssh_key_path)

  tags = {
    created_by_me = "TRUE"
  }
}