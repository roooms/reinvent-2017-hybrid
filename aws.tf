provider "aws" {
  region = "${var.aws_region}"
}

# Use module registry: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.0.4
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "${var.configuration_name}-vpc"
  cidr                 = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  azs            = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# Use module registry: https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/1.0.3
module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Launch configuration
  lc_name         = "${var.configuration_name}"
  image_id        = "${data.aws_ami.amazon_linux.id}"
  instance_type   = "t2.micro"
  key_name        = "${var.ssh_key_name}"
  security_groups = ["${aws_security_group.sg.id}"]
  user_data       = "${data.template_file.web_server_aws.rendered}"

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "8"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size = "8"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "${var.configuration_name}"
  vpc_zone_identifier       = "${module.vpc.public_subnets}"
  health_check_type         = "EC2"
  min_size                  = 3
  max_size                  = 3
  desired_capacity          = 3
  wait_for_capacity_timeout = 0
}

# Local resources:
resource "aws_security_group" "sg" {
  name        = "${var.configuration_name}-sg"
  description = "security group for ${var.configuration_name}"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Data sources:
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "template_file" "web_server_aws" {
  template = "${file("${path.module}/web-server.tpl")}"

  vars = {
    cloud_vendor = "aws"
  }
}
