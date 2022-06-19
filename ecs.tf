resource "aws_ecs_cluster" "retool" {
  name = var.deployment_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "retool_main" {
  family                   = "retool"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode(
    [
      {
        name      = "retool"
        essential = true
        image     = var.retool_image
        command = [
          "./docker_scripts/start_api.sh"
        ]

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.retool.id
            awslogs-region        = data.aws_region.current.name
            awslogs-stream-prefix = "retool"
          }
        }

        portMappings = [
          {
            containerPort = 3000
            protocol      = "tcp"
          }
        ]

        healthCheck = {
          command = [
            "CMD-SHELL",
            "curl -f http://127.0.0.1:3000/api/checkHealth || exit 1"
          ],
          interval    = 10
          timeout     = 5
          retries     = 3
          startPeriod = 3
        }

        environment = concat(
          local.environment_variables,
          [
            {
              name  = "SERVICE_TYPE"
              value = "MAIN_BACKEND,DB_CONNECTOR"
            },
            {
              "name"  = "COOKIE_INSECURE",
              "value" = "false"
            }
          ]
        )
      }
    ]
  )
}

resource "aws_ecs_service" "retool_main" {
  name             = "${var.deployment_name}-main"
  cluster          = aws_ecs_cluster.retool.id
  task_definition  = aws_ecs_task_definition.retool_main.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.retool.id]
    subnets          = var.private_subnet_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_retool.arn
    container_name   = "retool"
    container_port   = "3000"
  }
}

resource "aws_ecs_task_definition" "retool_jobs_runner" {
  family                   = var.deployment_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode(
    [
      {
        name      = "retool-jobs-runner"
        essential = true
        image     = var.retool_image
        command = [
          "./docker_scripts/start_api.sh"
        ]

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.retool.id
            awslogs-region        = data.aws_region.current.name
            awslogs-stream-prefix = "retool-jobs-runner"
          }
        }

        environment = concat(
          local.environment_variables,
          [
            {
              name  = "SERVICE_TYPE"
              value = "JOBS_RUNNER"
            }
          ]
        )
      }
    ]
  )
}

resource "aws_ecs_service" "retool_jobs_runner" {
  name             = "${var.deployment_name}-jobs-runner"
  cluster          = aws_ecs_cluster.retool.id
  task_definition  = aws_ecs_task_definition.retool_jobs_runner.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.retool.id]
    subnets          = var.private_subnet_ids
  }
}
