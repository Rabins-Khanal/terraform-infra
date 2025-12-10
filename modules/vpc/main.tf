variable "vpc_cidr" {}
variable "public_subnet1_cidr" {}
variable "public_subnet2_cidr" {}
variable "private_subnet1_cidr" {}
variable "private_subnet2_cidr" {}
variable "tags" { default = {} }
variable "environment" {}

data "aws_availability_zones" "available" {}

# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "terraformrnd-vpc-${var.environment}"
  })
}

# Public subnets
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet1_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = merge(var.tags, {
    Name = "terraformrnd-public1-subnet-${var.environment}"
  })
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet2_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = merge(var.tags, {
    Name = "terraformrnd-public2-subnet-${var.environment}"
  })
}

# Private subnets
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = merge(var.tags, {
    Name = "terraformrnd-private1-subnet-${var.environment}"
  })
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = merge(var.tags, {
    Name = "terraformrnd-private2-subnet-${var.environment}"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "terraformrnd-igw-${var.environment}"
  })
}

# Public Route Tables
resource "aws_route_table" "public1" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "terraformrnd-public1-rt-${var.environment}"
  })
}

resource "aws_route_table" "public2" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "terraformrnd-public2-rt-${var.environment}"
  })
}

# Associate public subnets with route tables
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public1.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public2.id
}

# Public route to IGW
resource "aws_route" "public1_igw" {
  route_table_id         = aws_route_table.public1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "public2_igw" {
  route_table_id         = aws_route_table.public2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Private Route Tables
resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "terraformrnd-private1-rt-${var.environment}"
  })
}

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "terraformrnd-private2-rt-${var.environment}"
  })
}

# Associate private subnets with private route tables
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private2.id
}

# NAT Gateway setup
resource "aws_eip" "nat" {
  vpc = true

  tags = merge(var.tags, {
    Name = "terraformrnd-nat-eip-${var.environment}"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id # NAT must be in public subnet

  tags = merge(var.tags, {
    Name = "terraformrnd-nat-${var.environment}"
  })
}

# Private route tables route to NAT
resource "aws_route" "private1_nat" {
  route_table_id         = aws_route_table.private1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route" "private2_nat" {
  route_table_id         = aws_route_table.private2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}
