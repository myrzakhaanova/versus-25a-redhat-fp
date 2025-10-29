project    = "versus-dev"
aws_region = "us-east-1"
vpc_id     = "vpc-07ca893c07f35fe20"

public_subnet_ids  = ["subnet-0e140948d0e50c23d", "subnet-0b0cdb50a1192dfe7", "subnet-0fcfed98671b7fea7"]
private_subnet_ids = ["subnet-05892762c10234b19", "subnet-0052763579a352700", "subnet-00568eae358324eca"]

instance_type        = "t3.micro"
ssh_key_name         = "test-key" 
systemd_service_name = "versus-backend"

app_port          = 3000
health_check_path = "/api" 

asg_min     = 1
asg_desired = 2
asg_max     = 3

backend_sg_id   = "sg-088cb0f4af42a8196"

backend_domain_name = "versus-app-backend.312redhat.com"
frontend_domain_name = "versus-app.312redhat.com"