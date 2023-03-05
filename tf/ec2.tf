resource "aws_key_pair" "deployer" {
  key_name   = "udemy-devops-key"
  public_key = var.public_key
  tags = {
    Terraform = "true"
  }
}

# TODO: use aws_ami data source instead of AMI ID

# data "aws_ami" "centos-7" {
#   owners      = ["679593333241"]
#   most_recent = true  

#   filter {
#       name   = "name"
#       values = ["CentOS Linux 7 x86_64 HVM EBS *"]
#   }

#   filter {
#       name   = "architecture"
#       values = ["x86_64"]
#   }

#   filter {
#       name   = "root-device-type"
#       values = ["ebs"]
#   }
# }

# TODO: modulerize the creation of EC2 instances

resource "aws_instance" "db_svc" {
  # ami                       = data.aws_ami.centos-7.id
  ami                         = "ami-002070d43b0a4f171"
  instance_type               = var.instance_type
  subnet_id                   = module.my_vpc.public_subnets[0]
  vpc_security_group_ids      = [module.sg_backend_svc.security_group_id]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = aws_key_pair.deployer.key_name
  user_data                   = file("../userdata/mysql.sh")
  
  tags = {
    Name    = "db_svc"
    Project = var.project_name
  }
}

resource "aws_instance" "memcached_svc" {
  ami                         = "ami-002070d43b0a4f171"
  instance_type               = var.instance_type
  subnet_id                   = module.my_vpc.public_subnets[0]
  vpc_security_group_ids      = [module.sg_backend_svc.security_group_id]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = aws_key_pair.deployer.key_name
  user_data                   = file("../userdata/memcache.sh")
  
  tags = {
    Name    = "memcached_svc"
    Project = var.project_name
  }
}

resource "aws_instance" "rabbitmq_svc" {
  ami                         = "ami-002070d43b0a4f171"
  instance_type               = var.instance_type
  subnet_id                   = module.my_vpc.public_subnets[0]
  vpc_security_group_ids      = [module.sg_backend_svc.security_group_id]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = aws_key_pair.deployer.key_name
  user_data                   = file("../userdata/rabbitmq.sh")
  
  tags = {
    Name    = "rabbitmq_svc"
    Project = var.project_name
  }
}