locals {
  resource_prefix = "yl-tf-ebs-ec2"
}

variable "env" {
  description = "Environment value. Can be used if you want to pass in a different value/variable as per environment. Default value can be set to dev"
  type = string
  default = "dev"  
}

resource "aws_instance" "public" {
  ami = data.aws_ami.amazon2023.id
  instance_type = "t2.micro"
  subnet_id = data.aws_subnets.public.ids[0]
  #subnet_id = "${var.subnet_id}"
  associate_public_ip_address = true
  #key_name = "yl-key-pair"
  #iam_instance_profile = aws_iam_instance_profile.tf_dynamodb_profile.name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    #Name = "${local.resource_prefix}-ec2-${var.env}"
    Name = "${local.resource_prefix}"
  }
}

resource "aws_security_group" "allow_ssh" {
  name_prefix = "${local.resource_prefix}-sg-${var.env}"
  description = "Allow SSH inbound and outbound"
  vpc_id = data.aws_vpc.selected.id
  #vpc_id = "${var.vpc_id}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_tls_ipv4_outbound" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 0
  ip_protocol = "tcp"
  to_port = 65535
}

resource "aws_ebs_volume" "yl-ebs" {
  availability_zone = aws_instance.public.availability_zone
  size              = 1
  type              = "gp3"
  iops              = 3000
  throughput        = 125

  tags = {
    Name = "yl-ebs-volume"
  }
}

resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.yl-ebs.id
  instance_id = aws_instance.public.id
}


