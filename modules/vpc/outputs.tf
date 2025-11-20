output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_id" { value = aws_subnet.public.id }
output "private_subnet_ids" { value = [aws_subnet.private1.id, aws_subnet.private2.id] }

