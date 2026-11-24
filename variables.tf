variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "alarm_threshold" {
  description = "CPU utilization alarm threshold"
  type        = number
  default     = 70
}
