
# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "EKS_VPC"
  }
}

#IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "IGW-EKS"
    Description = "The Internet Gateway should be attached to the VPC that contains the public subnet (which hosts the NAT Gateway)."
  }

}

# Private subnet
resource "aws_subnet" "Pvt-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-subnet-EKS-AZ1"
  }
}
# Private Subnet in AZ ap-south-1b
resource "aws_subnet" "Pvt-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-subnet-EKS-AZ2"
  }
}
# Public subnet 
resource "aws_subnet" "public-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-subnet-EKS"
  }

}

#Route Table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Public_RT-EKS"
  }

}

#Route to the Internet Gateway for the Public Route Table
resource "aws_route" "Public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

}

# Associate public Route Table with Public subnet
resource "aws_route_table_association" "Public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public-1.id

}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "EKS-EIP"
  }
}


# NAT Gateway
resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public-1.id
  allocation_id = aws_eip.nat.id
  tags = {
    Name = "EKS-NAT"
  }

}

# Private_Route table
resource "aws_route_table" "Private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Private_RT-EKS"
  }

}


#routes for PVT-RT
resource "aws_route" "pvt_nat" {
  route_table_id         = aws_route_table.Private.id
  destination_cidr_block = "0.0.0.0/0"            # Route all traffic
  nat_gateway_id         = aws_nat_gateway.nat.id # sends raffic to NAT Gateway

}

# Associate the Private Route Table with the Private Subnets
resource "aws_route_table_association" "Private1" {
  route_table_id = aws_route_table.Private.id
  subnet_id      = aws_subnet.Pvt-1.id

}

resource "aws_route_table_association" "Private2" {
  route_table_id = aws_route_table.Private.id
  subnet_id      = aws_subnet.Pvt-2.id

}

#IAM role for EKS CLuster
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}


# IAM role for worker nodes
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]

  })

}

resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}


# create eks cluster
resource "aws_eks_cluster" "Tester" {
  name     = "eks_Tester"
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    subnet_ids = [aws_subnet.Pvt-1.id, aws_subnet.Pvt-2.id]
  }

}

#create eks node group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.Tester.name
  node_group_name = "Tester-Node_Group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  scaling_config {
    max_size     = 4
    min_size     = 1
    desired_size = 2

  }
  # depends_on = [ 
  # aws_iam_role_policy_attachment.ecs_registry_policy,
  #  aws_iam_role_policy_attachment.eks_node_policy,
  #   aws_iam_role_policy_attachment.eks_cni_policy
  #   ]
  subnet_ids     = [aws_subnet.Pvt-1.id, aws_subnet.Pvt-2.id]
  instance_types = ["t3.medium"]
}

