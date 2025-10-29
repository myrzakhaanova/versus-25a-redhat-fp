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
  default = "subnet-0b0cdb50a1192dfe7"
}  

#sg
variable "sg_ids" {      
  type = list(string)
  default = ["sg-04807c939432a46da"]
}

# ==== Source (Ubuntu 22.04) ====
source "amazon-ebs" "ubuntu" {
  region        = var.region
  instance_type = "t3.small"
  ssh_username  = "ubuntu"

  # Optional: use your own VPC/Subnet/Security Groups for the build instance
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  security_group_ids          = var.sg_ids
  associate_public_ip_address = true
  ssh_interface               = "public_ip"

  # Use the latest official Ubuntu 22.04 AMI
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  ami_name = "versus-frontend-{{timestamp}}"
  tags = { Project = "VersusApp", Role = "Frontend" }
}

# ==== Build =======
build {
  name    = "versus-frontend"
  sources = ["source.amazon-ebs.ubuntu"]

  # 1) Create /tmp/src/frontend folder on the instance
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /tmp/src/frontend",
      "sudo chmod 777 /tmp/src/frontend"
    ]
  }

  # 2) Copy frontend source code (React app) into the instance
  provisioner "file" {
    source      = "../frontend/"         
    destination = "/tmp/src/frontend"
  }

  # 3) Copy .env.production file (environment variables for React build)
  provisioner "file" {
    source      = "../frontend/.env.production" 
    destination = "/tmp/src/frontend/"
  }

  # 4) Copy installation script and Nginx configuration
  provisioner "file" {
    source      = "scripts/install_frontend.sh"
    destination = "/tmp/install_frontend.sh"
  }

  provisioner "file" {
    source      = "nginx/frontend.conf"
    destination = "/tmp/frontend.conf"
  }

  # 5) Execute the installation script (build and configure frontend)
  provisioner "shell" {
    inline = [
      "chmod +x /tmp/install_frontend.sh",
      "sudo /tmp/install_frontend.sh"
    ]
  }
}