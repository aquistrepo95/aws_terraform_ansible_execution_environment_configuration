# Outputs for AWS EC2 instances

output "instance_ids_master" {
  description = "IDs of EC2 instances"
  value       = aws_instance.control_node.id
}

output "instance_ids_workers" {
  description = "IDs of EC2 worker instances"
  value       = aws_instance.worker-node[*].id
  
}

output "instance_public_ip_master" {
  description = "Public IP address of the master EC2 instance"
  value       = aws_instance.control_node.public_ip
}

output "instance_public_ip_workers" {
  description = "Public IP addresses of the worker EC2 instances"
  value       = aws_instance.worker-node[*].public_ip
}