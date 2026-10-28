variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Named AWS CLI profile to use."
  type        = string

  validation {
    condition = (
      length(trimspace(var.aws_profile)) > 0 &&
      var.aws_profile != "default"
    )
    error_message = "Provide a named AWS CLI profile other than default."
  }
}
variable "project_week2" {
  type    = string
  default = "week2"
}
variable "bucket_prefix" {
  type        = string
  description = "Prefix for the S3 bucket name."
}
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}
variable "instance_count" {
  description = "Number of EC2 instances to create."
  type        = number
  default     = 2
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "instance_count must be between 1 and 10."
  }

}
variable "instance_types" {
  description = "Type of EC2 instance to create."
  type        = map(string)
  default = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }
}
variable "ssh_allowed_cidrs" {
  description = "IP ranges allowed to connect over SSH."
  type        = list(string)
  default     = []
}
variable "availability_zones" {
  description = "Availability Zones to use for the project"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]

  validation {
  condition     = length(var.availability_zones) >= 1 && length(var.availability_zones) <= 3
  error_message = "Provide between one and three availability zones."
}
}
variable "http_allowed_cidrs" {
  description = "IP ranges allowed to access the website through HTTP"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
