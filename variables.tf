variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type = string
    default = "10.0.0.0/16"
}

# Subnets IP addresses
variable "subnet_cidrs" {
    description = "CIDR blocks for the subnets"
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

# Availability zones
variable "availability_zones" {
    description = "Availability zones for the subnets"
    type = list(string)
    default = ["us-east-1a", "us-east-1b", "us-east-1c"]

}
