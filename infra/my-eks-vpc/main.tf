resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name         = "${var.aws_stack_name}-VPC"
    created_by_me = "TRUE"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name         = "${var.aws_stack_name}-IGW"
    created_by_me = "TRUE"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "Public Subnets"
    Network = "Public"
    created_by_me = "TRUE"
  }
}

resource "aws_route_table" "private_route_table_01" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "Private Subnet AZ1"
    Network = "Private01"
    created_by_me = "TRUE"
  }
}

resource "aws_route_table" "private_route_table_02" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "Private Subnet AZ2"
    Network = "Private02"
    created_by_me = "TRUE"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat_gateway_eip_1" {
  vpc = true

  tags = {
    created_by_me = "TRUE"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat_gateway_eip_2" {
  vpc = true

  tags = {
    created_by_me = "TRUE"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway_01" {
  allocation_id = aws_eip.nat_gateway_eip_1.id
  subnet_id     = aws_subnet.public_subnet_01.id

  tags = {
    Name         = "${var.aws_stack_name}-NatGatewayAZ1"
    created_by_me = "TRUE"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway_02" {
  allocation_id = aws_eip.nat_gateway_eip_2.id
  subnet_id     = aws_subnet.public_subnet_02.id

  tags = {
    Name         = "${var.aws_stack_name}-NatGatewayAZ2"
    created_by_me = "TRUE"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "private_route_01" {
  route_table_id         = aws_route_table.private_route_table_01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_01.id

  depends_on = [aws_nat_gateway.nat_gateway_01]
}

resource "aws_route" "private_route_02" {
  route_table_id         = aws_route_table.private_route_table_02.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_02.id

  depends_on = [aws_nat_gateway.nat_gateway_02]
}

resource "aws_subnet" "public_subnet_01" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_01_block
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name         = "${var.aws_stack_name}-PublicSubnet01"
    "kubernetes.io/role/elb" = 1
    created_by_me = "TRUE"
  }
}

resource "aws_subnet" "public_subnet_02" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_02_block
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name         = "${var.aws_stack_name}-PublicSubnet02"
    "kubernetes.io/role/elb" = 1
    created_by_me = "TRUE"
  }
}

resource "aws_subnet" "private_subnet_01" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_01_block
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name         = "${var.aws_stack_name}-PrivateSubnet01"
    "kubernetes.io/role/internal-elb" = 1
    created_by_me = "TRUE"
  }
}

resource "aws_subnet" "private_subnet_02" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_02_block
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name         = "${var.aws_stack_name}-PrivateSubnet02"
    "kubernetes.io/role/internal-elb" = 1
    created_by_me = "TRUE"
  }
}

resource "aws_route_table_association" "public_subnet_01_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_01.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_02_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_02.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_01_route_table_association" {
  subnet_id      = aws_subnet.private_subnet_01.id
  route_table_id = aws_route_table.private_route_table_01.id
}

resource "aws_route_table_association" "private_subnet_02_route_table_association" {
  subnet_id      = aws_subnet.private_subnet_02.id
  route_table_id = aws_route_table.private_route_table_02.id
}

resource "aws_security_group" "control_plane_security_group" {
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    created_by_me = "TRUE"
  }
}

# Save outputs to Parameter Store
resource "aws_ssm_parameter" "vpc_id" {
  name  = "/vpc/id"
  type  = "String"
  value = aws_vpc.vpc.id
  tags = {
    created_by_me = "TRUE"
  }
}

resource "aws_ssm_parameter" "subnet_ids" {
  name  = "/vpc/subnet_ids"
  type  = "String"
  value = join(",", [aws_subnet.public_subnet_01.id, aws_subnet.public_subnet_02.id, aws_subnet.private_subnet_01.id, aws_subnet.private_subnet_02.id])
  tags = {
    created_by_me = "TRUE"
  }
}

resource "aws_ssm_parameter" "security_group_id" {
  name  = "/vpc/security_group_id"
  type  = "String"
  value = aws_security_group.control_plane_security_group.id
  tags = {
    created_by_me = "TRUE"
  }
}
