# Postgres RDS
# Create database subnet group

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "database subnet group"
  subnet_ids = [aws_subnet.private-subnet-1.id,  aws_subnet.private-subnet-2.id]

  tags = {
    Name = "rds_subnet_group"
  }
}


resource "aws_db_instance" "ECS-Postgres-DB" {
  allocated_storage = 10
  db_name             = "nayyadb"
  engine                 = "postgres"
  engine_version         = "13.7"
  instance_class         = "db.t3.micro"
  username               = "nayya"
  password               = "nayya123"
  storage_type           = "gp2"
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.DB-SG.id]
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  multi_az               = true
  tags = {
    name = "ECS-Postgres-DB"
  }
}
 
