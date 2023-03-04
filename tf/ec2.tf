resource "aws_key_pair" "deployer" {
  key_name   = "udemy-devops-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGLqcokPYBQEJQUanKnKame7Zn/ERMnrN+yumcT0XrwXOBArcHin4+uznzn63/gU4QkPmgPHQeQSjmGNhZEyscXgHt2pNju9mzLP9GK/MWpLEYFpzEs2KeNdw0/MU9KxICT8CZJTJQa7qNjy1pOaOg9nU81ml4CABUKVr4LjBr5S/OC6VMQGSembReNGlP2ijfV0Bt5HfdGKm1+YT3LA2Cq2lBqvX5qc+QyutfqKmCrrruCmhTVRQL90Bk8TKLU67zcG8Vs8KtRBysXw1vrEDvfZEe8ZFpnJ1D7fDOqupNFugNcLET2pd2zpvWI+nbsnXGKAZJ8wVw1nLKBc9oYz0v rodericuus@woo"
  tags = {
    Terraform = "true"
  }
}

data "aws_ami" "centos-7" {
  owners      = ["679593333241"]
  most_recent = true  

  filter {
      name   = "name"
      values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
      name   = "architecture"
      values = ["x86_64"]
  }

  filter {
      name   = "root-device-type"
      values = ["ebs"]
  }
}

// TODO modulerize the creation of EC2 instances

resource "aws_instance" "linux-server" {
  ami                         = data.aws_ami.centos-7.id
  instance_type               = var.instance_type
  subnet_id                   = module.my_vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.aws-linux-sg.id]
  associate_public_ip_address = var.linux_associate_public_ip_address
  source_dest_check           = false
  key_name                    = aws_key_pair.key_pair.key_name
  user_data                   = file("../userdata/aws-user-data.sh")
  
  # root disk
  root_block_device {
    volume_size           = var.linux_root_volume_size
    volume_type           = var.linux_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }# extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.linux_data_volume_size
    volume_type           = var.linux_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }
  
  tags = {
    Name = "linux-vm"
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name    = "HelloWorld"
    Project = var.project_name
  }
}