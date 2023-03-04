variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t2.micro"
}

variable "project_name" {
  default = "vprofile"
}

variable "ami_filter" {
  description = "Name filter and owner for AMI"

  type = object({
    name  = string
    owner = string
  })

  default = {
    name  = "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
    owner = "979382823631" # Bitnami
  }
}

variable "environment" {
  description = "Dev Environment"

  type = object({
    name           = string
    network_prefix = string
  })

  default = {
    name           = "dev"
    network_prefix = "10.0"
  }
}

variable "asg_sizes" {
  description = "Min and max ASG sizes"

  type = object({
    min_size = number
    max_size = number
  })

  default = {
      min_size = 1
      max_size = 2
  }
}