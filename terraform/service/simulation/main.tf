variable "env" {
  type = string
}

variable "table_name" {
  type = string
}

variable "table_arn" {
  type = string
}

resource "aws_ecr_repository" "simulation_repo" {
  name = "snack-simulation-${var.env}"
}

resource "aws_ecs_cluster" "snack_cluster" {
  name = "snack-cluster-${var.env}"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "dynamodb_access_sim-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        Resource = var.table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

resource "aws_ecs_task_definition" "simulation_task" {
  family                   = "snack-simulation-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "simulation"
      image     = "${aws_ecr_repository.simulation_repo.repository_url}:latest"
      cpu       = 2048
      memory    = 4096
      essential = true
      environment = [
        { name = "DYNAMODB_TABLE", value = var.table_name },
      ]
    }
  ])
}
