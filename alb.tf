# Create target group
resource "aws_lb_target_group" "alb-Target-group" {
  health_check {
    interval            = 200
    path                = "/"
    protocol            = "HTTP"
    timeout             = 60
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  name        = "alb-tg"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "alb-tg"
  }
}

#Create Internet-facing ALB 
resource "aws_lb" "ecs-alb" {
  name               = "ecs-loadbalancer1"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  enable_deletion_protection = false

  tags = {
    name = "ecs-alb"
  }
}


# Create listener
# Listener rule for HTTPs traffic on ALB
resource "aws_lb_listener" "alb-listener-https" {
  load_balancer_arn = aws_lb.ecs-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = aws_acm_certificate.ecs-cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-Target-group.id
  }
}


# Listener rule for HTTP traffic on ALB
resource "aws_lb_listener" "alb-listener-http" {
  load_balancer_arn = aws_lb.ecs-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-Target-group.id
  }
}