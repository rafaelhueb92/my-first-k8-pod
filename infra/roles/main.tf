resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = {
    created_by_me = "TRUE"
  }

}

resource "aws_iam_policy_attachment" "eks_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  roles      = [aws_iam_role.eks_role.name]
  name       = "${local.application_name}-role-policy-attachment"
}

resource "aws_iam_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  roles      = [aws_iam_role.eks_role.name]
  name       = "${local.application_name}-service-policy-attachment"
}

# EC2 Role for EKS Worker Nodes
resource "aws_iam_role" "ec2_role" {
  name = "eks-worker-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = {
    created_by_me = "TRUE"
  }

}

resource "aws_iam_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  roles      = [aws_iam_role.ec2_role.name]
  name       = "ec2-eks-cni-policy-attachment"
}

resource "aws_iam_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  roles      = [aws_iam_role.ec2_role.name]
  name       = "ec2-eks-worker-node-policy-attachment"
}

resource "aws_iam_policy_attachment" "ecr_readonly_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  roles      = [aws_iam_role.ec2_role.name]
  name       = "ec2-ecr-readonly-policy-attachment"
}

# Save ARNs to Parameter Store
resource "aws_ssm_parameter" "eks_role_arn" {
  name  = "/eks/role/arn"
  type  = "String"
  value = aws_iam_role.eks_role.arn
  tags = {
    created_by_me = "TRUE"
  }
}

resource "aws_ssm_parameter" "ec2_role_arn" {
  name  = "/ec2/role/arn"
  type  = "String"
  value = aws_iam_role.ec2_role.arn
  tags = {
    created_by_me = "TRUE"
  }
}