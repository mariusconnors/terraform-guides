variable "name" { default = "dynamic-aws-creds-consumer" }
variable "path" { default = "../producer-workspace/terraform.tfstate" }
variable "ttl"  { default = "1" }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "terraform_remote_state" "producer" {
  backend = "local"

  config = {
    path = "${var.path}"
  }
}

data "vault_aws_access_credentials" "creds" {
  backend = "${data.terraform_remote_state.producer.outputs.backend}"
  role    = "${data.terraform_remote_state.producer.outputs.role}"
}

provider "aws" {
  access_key = "${data.vault_aws_access_credentials.creds.access_key}"
  secret_key = "${data.vault_aws_access_credentials.creds.secret_key}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Create AWS EC2 Instance
resource "aws_instance" "main" {
  BlockDeviceMappings.Ebs.Encrypted = true
  # oak9: KeyName is not configured
  NetworkInterfaces.AssociatePublicIpAddress = false
  # oak9: NetworkInterfaces.GroupSet is not configured
  # oak9: SecurityGroupIds is not configured
  # oak9: aws_ec2_client_vpn_network_association.security_groups is not configured
  SourceDestCheck = false
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.nano"

  tags = {
    Name  = "${var.name}"
    TTL   = "${var.ttl}"
    owner = "${var.name}-guide"
  }
}
