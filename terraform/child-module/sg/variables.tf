variable "project" {
  description = "Short project name used as a prefix for resource naming."
  type        = string
  default     = "versus"
}

variable "vpc_id" {
  description = "The ID of the existing VPC where resources will be created."
  type        = string
}