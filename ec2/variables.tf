variable "aws_instance" {
    type = object({
          ami = string
    security_groups = list(string)
    instance_type = string
    key_name = string
    associate_public_ip_address = bool
    tags = map(string)
    })
  
}

variable "region" {
  type = string
}

