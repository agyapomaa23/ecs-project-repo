#Creating ECS Clusters
resource "aws_ecs_cluster" "ecs_ngnix" {
  name = "myecscluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


#Task Definitions
resource "aws_ecs_task_definition" "service-taskdefinition" {
  family                   = "nginxtaskdefined"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  task_role_arn            = aws_iam_role.ecs_tasks_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn
  container_definitions    = <<TASK_DEFINITION
[
 {
   "name": "nginxcontainer",
   "image": "332984147329.dkr.ecr.eu-west-2.amazonaws.com/mynginx",
   "cpu": 1024,
   "memory": 2048,
   "portMappings":[
       {
         "name":"nginxcontainter-80-tcp", 
         "containerPort":80,
         "hostPort":80,
         "protocol":"tcp",
         "appProtocol":"http"
       }
   ],
   "essential":true
 }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}


#Creating ECS Service to Run Tasks
resource "aws_ecs_service" "ngnixservice" {
  name                               = "nginxservice"
  cluster                            = aws_ecs_cluster.ecs_ngnix.id
  task_definition                    = aws_ecs_task_definition.service-taskdefinition.arn
  desired_count                      = 2
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  scheduling_strategy                = "REPLICA"



  network_configuration {
    security_groups  = [aws_security_group.ecs-sg.id]
    subnets          = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb-Target-group.arn
    container_name   = "nginxcontainer"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}


#Autoscaling for the Service
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity = 4
  min_capacity = 2
  resource_id  = "service/${aws_ecs_cluster.ecs_ngnix.name}/${aws_ecs_service.ngnixservice.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


#Auotscaling policy 
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 70
  }
}
