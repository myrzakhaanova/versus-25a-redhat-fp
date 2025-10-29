variable "project" {
  description = "Short project name used as a prefix for resource naming."
  type        = string
  default     = "versus"
}

variable "vpc_id" {
  description = "The ID of the existing VPC where resources will be created."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the Application Load Balancer."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Auto Scaling Group instances."
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for application servers."
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "Name of the existing SSH key pair (for EC2 access). Set to null if not used."
  type        = string
  default     = null
}

variable "asg_min" {
  description = "Minimum number of instances in the Auto Scaling Group."
  type        = number
  default     = 1
}

variable "asg_desired" {
  description = "Desired number of instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "asg_max" {
  description = "Maximum number of instances in the Auto Scaling Group."
  type        = number
  default     = 3
}

variable "enable_instance_refresh" {
  description = "Enable instance refresh in the Auto Scaling Group when the launch template changes."
  type        = bool
  default     = true
}

variable "service" {
  description = "Deployment environment (e.g., dev, staging, prod)."
  type        = string
  
}

variable "ec2_sg_ids" {
  description = "List of Security Group IDs to attach to EC2 instances."
  type        = list(string)
  default     = []
}

variable "alb_sg_ids" {
  description = "List of Security Group IDs to attach to the Application Load Balancer."
  type        = list(string)
  default     = []
  
}

variable "aws_instance_profile_name" {
  description = "Name of the IAM instance profile to attach to EC2 instances."
  type        = string
  
}

variable "health_check_path" {
  description = "Path used by ALB for health checks."
  type        = string
}

variable "health_check_matcher" {
  description = "HTTP codes to use when checking for a successful response from a target."
  type        = string
}

variable "domain_name" {
  type    = string
}

