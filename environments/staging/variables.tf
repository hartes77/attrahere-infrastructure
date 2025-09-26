# environments/staging/variables.tf

variable "vpc_name" {
  description = "Name of the staging VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the staging VPC"
  type        = string
}

variable "vpc_azs" {
  description = "Availability zones for the staging VPC"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "Private subnets for the staging VPC"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "Public subnets for the staging VPC"
  type        = list(string)
}