data "aws_ami" "amazon2023" {
  most_recent = true

  filter {
    name = "name"
    values = ["al2023-ami-2023*-kernel-6.1-x86_64"]
  }
  owners = ["amazon"]
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["yl-ebs-vpc"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}


