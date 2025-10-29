packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

variable "region" {
  default = "us-east-1"
}

variable "vpc_id"       {
  default = "vpc-07ca893c07f35fe20"
}   

variable "subnet_id"    {
  type    = string
  default = "subnet-0e140948d0e50c23d"
}  

variable "sg_ids" {      
  type = list(string)
  default = ["sg-04807c939432a46da"]
}

source "amazon-ebs" "ubuntu" {
  region        = var.region
  instance_type = "t3.micro"
  ssh_username  = "ubuntu"

  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id
  security_group_ids = var.sg_ids

  associate_public_ip_address = true
  ssh_interface               = "public_ip"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  ami_name = "versus-backend-{{timestamp}}"

  tags = {
    Project = "VersusApp"
  }
}

#building_ami
build {
  name    = "versus-ami"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /tmp/src/backend",
      "sudo chmod 777 /tmp/src/backend"
    ]
  }

  # Copy backend code
  provisioner "file" {
    source      = "../backend/"
    destination = "/tmp/src/backend"
  }

  #file
  provisioner "file" {
    source      = "../backend/.env"
    destination = "/tmp/envfile"
  }

  # Copy Nginx config
  provisioner "file" {
    source      = "nginx/versus.conf"
    destination = "/tmp/versus.conf"
  }

  # Copy systemd unit
  provisioner "file" {
    source      = "systemd/versus-backend.service"
    destination = "/tmp/versus-backend.service"
  }

  # Install dependencies and configure service (script)
  provisioner "shell" {
    script = "scripts/install.sh"
  }
}