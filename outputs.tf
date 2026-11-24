output "vpc_id" {
  description = "Project 3 VPC ID"
  value       = aws_vpc.project_vpc.id
}

output "subnet_id" {
  description = "Project 3 subnet ID"
  value       = aws_subnet.project_subnet.id
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.monitoring.id
}

output "instance_type" {
  description = "EC2 instance type"
  value       = aws_instance.monitoring.instance_type
}

output "private_ip" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.monitoring.private_ip
}

output "cpu_alarm_name" {
  description = "CloudWatch CPU alarm name"
  value       = aws_cloudwatch_metric_alarm.cpu.alarm_name
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}
