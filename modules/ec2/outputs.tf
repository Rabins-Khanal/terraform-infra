output "ec2_id" { value = aws_instance.ec2.id }
output "ec2_sg_id" { value = aws_security_group.ec2_sg.id }

