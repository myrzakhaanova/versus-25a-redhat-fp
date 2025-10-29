variable "project" {
  description = "Short project name used as a prefix for resource naming."
  type        = string
  default     = "versus"
}

variable "aws_region" {
  description = "AWS region where infrastructure will be deployed."
  type        = string
  default     = "us-east-1"
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

variable "systemd_service_name" {
  description = "Name of the systemd service to start on instance boot."
  type        = string
  default     = "versus-frontend"
}

variable "app_port" {
  description = "Port number where the application listens for requests."
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "Path used by ALB for health checks."
  type        = string
  default     = "/"
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

variable "backend_sg_id" {
  description = "Security Group ID for backend instances (if needed)."
  type        = string
}

variable "backend_domain_name" {
  description = "Domain name for the backend service (used in Route53 record)."
  type        = string
}

variable "frontend_domain_name" {
  description = "Domain name for the frontend service (used in Route53 record)."
  type        = string

}