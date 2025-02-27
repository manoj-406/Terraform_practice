variable "region" {
  type        = string
  default     = "ap-south-1"
  description = "variable for providers region"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "variable for vpc network range"
}

variable "subnet_cidr" {
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "Variable for subnet cidr"

}

variable "availability_zone" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}
