output "vpc_id" {
  value       = aws_vpc.main.id
  description = "vpc-id"
}

output "Public_subnet_ids" {
  value = [aws_subnet.public-1.id, aws_subnet.public-2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private-1.id, aws_subnet.private-2.id]
}
