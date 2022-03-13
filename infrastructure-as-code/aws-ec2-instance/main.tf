terraform {
  required_version = ">= 0.11.0"
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_instance" "ubuntu" {
  BlockDeviceMappings.Ebs.Encrypted = true
  # oak9: KeyName is not configured
  NetworkInterfaces.AssociatePublicIpAddress = false
  # oak9: NetworkInterfaces.GroupSet is not configured
  # oak9: SecurityGroupIds is not configured
  # oak9: aws_ec2_client_vpn_network_association.security_groups is not configured
  SourceDestCheck = false
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  availability_zone = "${var.aws_region}a"

  tags {
    Name = "${var.name}"
  }
}
