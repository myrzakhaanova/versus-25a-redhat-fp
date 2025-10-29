Versus on EC2 — Deployment Package (Packer + Terraform + GitHub Actions)

A mid-to-large scale, interview-ready project demonstrating immutable AMIs on EC2, Infrastructure as Code with Terraform, and fully automated CI/CD with GitHub Actions. This README is aligned to your current repository structure.

App: Django (API) + React (UI) • Infra: EC2 + ALB + ASG + RDS (MySQL) + Route 53 • Automation: Packer • Terraform • GitHub Actions • systemd • Nginx

⸻

Story & Objectives

The goal of this project is to create a comprehensive deployment package for the Versus App running on AWS EC2. The package includes:
	•	Custom AMIs built with Packer, configured with systemd services for automatic startup and recovery.
	•	Terraform for infrastructure provisioning: VPC, Security Groups, ALB, Auto Scaling Groups, IAM roles, and Route 53 DNS.
	•	GitHub Actions for automated AMI builds, Terraform deployments, and post-deployment health checks.
	•	Clear documentation for replication, demo, and interview purposes.

⸻

Repository Structure 

Project directories and files include:
	•	backend/ – Django-based API application
	•	frontend/ – React-based web application with Nginx
	•	packer-backend/ and packer-frontend/ – Packer templates for AMI creation
	•	terraform/ – Infrastructure as Code with modules for ALB, ASG, and Security Groups
	•	.github/workflows/ – CI/CD pipelines for automation

⸻

Architecture Overview

The infrastructure uses separate Auto Scaling Groups for the frontend and backend, both behind an Application Load Balancer. The ALB routes traffic based on path and health checks. The backend connects to an AWS RDS MySQL database. DNS is managed by Route 53 using Alias records pointing to the ALB.

⸻

Environments & DNS

Domain naming convention:
versus-on-vms-TEAM-dev.TEAM_DOMAIN

Each environment has its own Route 53 hosted zone, with Alias A records pointing to the ALB. Initially, the ALB DNS is used for testing, followed by DNS aliasing for production.

⸻

Packer (AMI Creation)

Backend AMI:
	•	Based on Ubuntu.
	•	Installs Python, Gunicorn, Nginx, and the Django app.
	•	Configures a systemd service (versus-backend.service) for automatic startup on reboot.

Frontend AMI:
	•	Installs Node.js and Yarn.
	•	Builds the React application and configures Nginx to serve static content.
	•	Enables Nginx as a systemd service.

Short commands:
	•	cd packer-backend && packer build versus-ami.pkr.hcl
	•	cd packer-frontend && packer build scripts/versus-frontend-ami.pkr.hcl

The resulting AMI IDs are passed to Terraform.

⸻

Terraform (Infrastructure)

Terraform provisions all required AWS infrastructure:
	•	VPC, Subnets, Internet Gateway
	•	Security Groups for ALB, Backend, Frontend, and RDS
	•	Application Load Balancer and Auto Scaling Groups for each tier
	•	IAM roles and Route 53 DNS configuration

Main files:
	•	terraform/main.tf – root infrastructure definition
	•	terraform/child-module/sg – security group definitions
	•	terraform/child-module/alb-asg – ALB and ASG setup

Short commands:
	•	terraform init
	•	terraform plan
	•	terraform apply

⸻

CI/CD (GitHub Actions)

GitHub Actions is configured with OIDC authentication to AWS (no long-term access keys).

Pipeline steps:
	1.	Build backend and frontend AMIs with Packer.
	2.	Apply Terraform to deploy or update infrastructure.
	3.	Run smoke tests to validate application health via the ALB URL.

Branch strategy:
	•	feature/** → development environment
	•	staging → staging environment
	•	main → production environment

Essential repository variables:
	•	AWS_REGION
	•	IAM_ROLE
	•	DOMAIN

⸻

Validation & Demo

Deployment verification checklist:
	•	The application is accessible via the ALB DNS or custom domain.
	•	Backend health check /api/healthz returns HTTP 200.
	•	ASG automatically replaces failed instances.

⸻

Operations

Useful operational commands:
	•	sudo systemctl status versus-backend
	•	sudo journalctl -u versus-backend -e
	•	aws elbv2 describe-target-health

⸻

Troubleshooting
	1.	ALB 5xx Errors – Check target health, security group rules, and systemd service status.
	2.	Database Authentication Issues – Compare credentials in /etc/versus/backend.env and AWS Secrets Manager.
	3.	App Not Running – Check systemd status and logs to ensure services are enabled.
	4.	Incorrect AMI – Verify Terraform variables and refresh Launch Template versions.

⸻

Interview Talking Points
	•	Immutable AMIs ensure consistent, reliable deployments.
	•	Using systemd instead of npm start for auto-restart and lifecycle management.
	•	ALB + ASG enable fault tolerance and blue/green-style rollouts.
	•	Secrets handled via AWS SSM/Secrets Manager for security.
	•	OIDC authentication eliminates the need for AWS credentials in CI/CD.

⸻

Real-World Notes: GitLab vs GitHub vs Bitbucket
	•	GitHub – Strong integration with Actions, large ecosystem.
	•	GitLab – Built-in DevOps suite including CI/CD, package registry, and Terraform state management.
	•	Bitbucket – Best for teams using Jira and Confluence (Atlassian integration).

Git commands remain the same across all platforms.

⸻

Success Criteria
	•	Pipeline successfully builds AMIs and deploys infrastructure.
	•	Application is reachable and functional via ALB or domain.
	•	ASG ensures resilience with auto-recovery.
	•	README fully documents the process for demo and interview discussions.