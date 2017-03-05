variable "account_id" {}
variable "aws_region" {}

variable "vpc_id" {}
variable "vpc_cidr_block" {}

# Roles that will be given access to EFS filesystem
variable "roles" {}

# Subnets where EFS mount targets will be created
variable "subnets" {}
variable "subnets_count" {}
variable "filesystem_name" {}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
