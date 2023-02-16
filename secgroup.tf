# Configuring internet-facing Load balancer Security Group
resource "aws_security_group" "alb-sg" {
  name        = "alb-securitygroup"
  description = "Allow HTTP and HTTPS inbound traffic"
  vpc_id      = aws_vpc.vpc.id
  # Inbound Rules
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-securitygroup"
  }
}


# Configuring ESC Service Security Group 
resource "aws_security_group" "ecs-sg" {
  name        = "ecs-securitygroup"
  description = "Allow inbound traffic from alb-sg"
  vpc_id      = aws_vpc.vpc.id

  # Inbound Rules
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  # Outbound Rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-securitygroup"
}
}


# Configuring RDS Postgres Security Group
resource "aws_security_group" "DB-SG" {
  name        = "db-securitygroup"
  description = "Allow inbound traffic from ecs-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs-sg.id]
  }

  tags = {
    Name = "db-securitygroup"
  }
}