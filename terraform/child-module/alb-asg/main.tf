
data "aws_acm_certificate" "issued" {
  domain      = "versus-app.312redhat.com"
  statuses    = ["ISSUED"]
  most_recent = true
}

# Fetch latest Versus AMI built by Packer
data "aws_ami" "versus_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["versus-${var.service}-*"]
  }

  owners = ["self"] # Only your account’s AMIs
}


############################################
# Application Load Balancer + Target Group + Listener
############################################
resource "aws_lb" "app_alb" {
  name               = "${var.project}-${var.service}-alb" 
  load_balancer_type = "application"
  security_groups    = var.alb_sg_ids
  subnets            = var.public_subnet_ids
  idle_timeout       = 60
  tags               = { Project = var.project }
}

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.project}-${var.service}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 15
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = var.health_check_matcher 
  }

  tags = { Project = var.project }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

############################################
# Launch Template (uses your application AMI)
############################################
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project}-${var.service}-lt-"
  image_id      = data.aws_ami.versus_ami.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.aws_instance_profile_name
  }

  vpc_security_group_ids = var.ec2_sg_ids
  key_name               = var.ssh_key_name
  update_default_version = true

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project}-${var.service}"
      Project = var.project
    }
  }
}

############################################
# Auto Scaling Group
############################################
resource "aws_autoscaling_group" "app_asg" {
  name                      = "${var.project}-${var.service}-asg"
  desired_capacity          = var.asg_desired
  max_size                  = var.asg_max
  min_size                  = var.asg_min
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 90

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  dynamic "instance_refresh" {
    for_each = var.enable_instance_refresh ? [1] : []
    content {
      strategy = "Rolling"
      preferences {
        min_healthy_percentage = 90
        instance_warmup        = 60
      }
      triggers = ["launch_template"]
    }
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }
}

data "aws_route53_zone" "main" {
  name         = "312redhat.com."
  private_zone = false
}

resource "aws_route53_record" "app_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name            
  type    = "A"

  alias {
    name                   = aws_lb.app_alb.dns_name
    zone_id                = aws_lb.app_alb.zone_id
    evaluate_target_health = true
  }
}