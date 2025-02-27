#vpc
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    from = "tf"
    Name = "tf-vpc"
  }
}


#Public_subnets
resource "aws_subnet" "public-1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr[0]
  availability_zone = var.availability_zone[0]
  tags = {
    app  = "web-1"
    Name = "web-1"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "public-2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr[1]
  availability_zone = var.availability_zone[1]
  tags = {
    app  = "web-2"
    Name = "web-2"
  }
  depends_on = [aws_vpc.main]
}

#private_subnet
resource "aws_subnet" "private-1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr[2]
  availability_zone = var.availability_zone[0]
  tags = {
    app  = "db-1"
    Name = "db-1"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "private-2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr[3]
  availability_zone = var.availability_zone[1]
  tags = {
    app  = "db-2"
    Name = "db-2"
  }
  depends_on = [aws_vpc.main]
}


