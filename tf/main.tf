# data "aws_ami" "app_ami" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = [var.ami_filter.name]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = [var.ami_filter.owner]
# }

module "my_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.environment.name
  cidr = "${var.environment.network_prefix}.0.0/16"

  azs             = ["${var.aws_region}a","${var.aws_region}b","${var.aws_region}c"]
  public_subnets  = ["${var.environment.network_prefix}.101.0/24", "${var.environment.network_prefix}.102.0/24", "${var.environment.network_prefix}.103.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = var.environment.name
  }
}

# module "autoscaling" {
#   source  = "terraform-aws-modules/autoscaling/aws"
#   version = "6.5.2"
  
#   name     = "${var.environment.name}-blog"
#   min_size = var.asg_sizes.min_size
#   max_size = var.asg_sizes.max_size

#   vpc_zone_identifier = module.blog_vpc.public_subnets
#   target_group_arns   = module.blog_alb.target_group_arns
#   security_groups     = [module.blog_sg.security_group_id]

#   image_id      = data.aws_ami.app_ami.id
#   instance_type = var.instance_type
# }

# module "blog_alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "~> 8.0"

#   name = "${var.environment.name}-blog-alb"

#   load_balancer_type = "application"

#   vpc_id             = module.blog_vpc.vpc_id
#   subnets            = module.blog_vpc.public_subnets
#   security_groups    = [module.blog_sg.security_group_id]

#   target_groups = [
#     {
#       name_prefix      = "${var.environment.name}-"
#       backend_protocol = "HTTP"
#       backend_port     = 80
#       target_type      = "instance"
#     }
#   ]

#   http_tcp_listeners = [
#     {
#       port               = 80
#       protocol           = "HTTP"
#       target_group_index = 0
#     }
#   ]

#   tags = {
#     Environment = var.environment.name
#   }
# }

module "sg_elb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"

  name = "sg_elb"
  description = "Security Group for ELB"

  vpc_id = module.my_vpc.vpc_id

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

module "sg_webapp" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"

  name = "sg_webapp"
  description = "Security Group for WebApp"

  vpc_id = module.my_vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow traffic from ELB"
      source_security_group_id = module.sg_elb.security_group_id
    },
  ]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

module "sg_backend_svc" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"

  name        = "sg_backend_svc"
  description = "Security Group for Backend Services"

  vpc_id = module.my_vpc.vpc_id
  
  # ingress_rules       = ["ssh-tcp"]
  # TODO: Allow SSH traffic only from EC2 Connect
  # ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_with_self = [{
    rule        = "all-all"
    description = "Allow internal traffic"
  }]

  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.sg_webapp.security_group_id
      description              = "Allow traffic from App Server to DB"
    },
    {
      rule                     = "rabbitmq-5672-tcp"
      source_security_group_id = module.sg_webapp.security_group_id
      description              = "Allow traffic from App Server to rabbitMQ"
    },
    {
      rule                     = "memcached-tcp"
      source_security_group_id = module.sg_webapp.security_group_id
      description              = "Allow traffic from App Server to memcached"
    },
  ]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}