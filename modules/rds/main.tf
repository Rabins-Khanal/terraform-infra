resource "aws_db_subnet_group" "this" {
  name       = "terraformrnd-db-subnet-${var.environment}"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "terraformrnd-db-subnet-${var.environment}"
  })
}

resource "aws_security_group" "rds_sg" {
  name   = "terraformrnd-rds-sg-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "terraformrnd-rds-sg-${var.environment}"
  })
}

resource "aws_db_instance" "this" {
  identifier             = "terraformrnd-rds-${var.environment}"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = merge(var.tags, {
    Name = "terraformrnd-rds-${var.environment}"
  })
}

