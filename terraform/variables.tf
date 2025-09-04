variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}