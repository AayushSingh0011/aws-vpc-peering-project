output "bastion_public_ip" {
  description = "Public IPv4 of the Bastion instance"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of Bastion"
  value       = aws_instance.bastion.private_ip
}

output "app_a_private_ip" {
  description = "Private IP of App-A"
  value       = aws_instance.app_a.private_ip
}

output "app_b_private_ip" {
  description = "Private IP of App-B"
  value       = aws_instance.app_b.private_ip
}

output "vpc_peering_id" {
  description = "VPC Peering Connection ID"
  value       = aws_vpc_peering_connection.peering.id
}

output "vpc_a_id" {
  description = "VPC A ID"
  value       = aws_vpc.vpc_a.id
}

output "vpc_b_id" {
  description = "VPC B ID"
  value       = aws_vpc.vpc_b.id
}
