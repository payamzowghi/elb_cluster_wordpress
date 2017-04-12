#AWS access_key
variable "access_key" {
  description = "AWS-access-key"
}

#AWS secret_key
variable "secret_key" {
  description = "AWS-secret-key"
}

#AWS region
variable "region" {
  description = "AWS region"
}

#pair-key
variable "key_name" {
  description = "AWS_key_pair"
  default     = "wordpress_key"
}

#instance type
variable "instance_type" {
  description = "Instance type"
  default     = "t2.micro"
}

#name of vpc
variable "name" {
  description = "Name of the VPC"
  default     = "wordpress_vpc"
}

#name of database
variable "name-db" {
  description = "Name of the VPC"
  default     = "wordpress"
}

#cidr for vpc
variable "cidr" {
  description = "CIDR of the VPC"
  default     = "172.16.0.0/16"
}

#DNS_hostname
variable "enable_dns_hostnames" {
  description = "true if you want to use private DNS within the VPC"
  default     = true
}

#enable DNS
variable "enable_dns_support" {
  description = "true if you want to use private DNS within the VPC"
  default     = true
}

#password of db
variable "db_password" {
  description = "The password for the database"
}
