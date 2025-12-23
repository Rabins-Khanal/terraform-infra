#
resource "aws_security_group" "ec2_sg" {
  name        = "terraformrnd-ec2-sg-${var.environment}"
  description = "EC2 security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["160.250.254.145/32",
    "202.166.207.89/32"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["160.250.254.145/32",
    "202.166.207.89/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "terraformrnd-ec2-sg-${var.environment}"
  })
}

resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = merge(var.tags, {
    Name = "terraformrnd-ec2-${var.environment}"
  })
}

