resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "terraformrnd-vpc-${var.environment}"
  })
}

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

data "aws_availability_zones" "available" {}

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

#public route Tables association

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public1.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public2.id
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

# Associate private subnets
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private2.id
}

