resource "aws_dynamodb_table" "carts" {
  name         = "carts-bedrock-${var.student_id}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "customerId"
    type = "S"
  }

  global_secondary_index {
    name            = "idx_global_customerId"
    hash_key        = "customerId"
    projection_type = "ALL"
  }

  tags = {
    Project = "karatu-2025-capstone"
  }
}

output "carts_dynamodb_table_name" {
  value = aws_dynamodb_table.carts.name
}

# --- RDS MySQL for catalog service ---

resource "aws_db_subnet_group" "catalog_mysql" {
  name       = "catalog-mysql-subnet-group-${var.student_id}"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_security_group" "catalog_mysql" {
  name        = "catalog-mysql-sg-${var.student_id}"
  description = "Allow MySQL access from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "MySQL from EKS nodes"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_db_instance" "catalog_mysql" {
  identifier             = "catalog-mysql-${var.student_id}"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "catalog"
  username               = "catalog_admin"
  password               = "TempPassword123!"
  db_subnet_group_name   = aws_db_subnet_group.catalog_mysql.name
  vpc_security_group_ids = [aws_security_group.catalog_mysql.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Project = "karatu-2025-capstone"
  }
}

output "catalog_mysql_endpoint" {
  value = aws_db_instance.catalog_mysql.endpoint
}

# --- RDS PostgreSQL for orders service ---

resource "aws_db_subnet_group" "orders_postgresql" {
  name       = "orders-postgresql-subnet-group-${var.student_id}"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_security_group" "orders_postgresql" {
  name        = "orders-postgresql-sg-${var.student_id}"
  description = "Allow PostgreSQL access from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_db_instance" "orders_postgresql" {
  identifier             = "orders-postgresql-${var.student_id}"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "orders"
  username               = "orders_admin"
  password               = "TempPassword123!"
  db_subnet_group_name   = aws_db_subnet_group.orders_postgresql.name
  vpc_security_group_ids = [aws_security_group.orders_postgresql.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Project = "karatu-2025-capstone"
  }
}

output "orders_postgresql_endpoint" {
  value = aws_db_instance.orders_postgresql.endpoint
}

# --- Secrets Manager for DB credentials ---

resource "aws_secretsmanager_secret" "catalog_mysql" {
  name = "catalog-mysql-credentials-${var.student_id}"

  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_secretsmanager_secret_version" "catalog_mysql" {
  secret_id = aws_secretsmanager_secret.catalog_mysql.id
  secret_string = jsonencode({
    username = aws_db_instance.catalog_mysql.username
    password = aws_db_instance.catalog_mysql.password
    host     = aws_db_instance.catalog_mysql.address
    port     = 3306
    dbname   = aws_db_instance.catalog_mysql.db_name
  })
}

resource "aws_secretsmanager_secret" "orders_postgresql" {
  name = "orders-postgresql-credentials-${var.student_id}"

  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_secretsmanager_secret_version" "orders_postgresql" {
  secret_id = aws_secretsmanager_secret.orders_postgresql.id
  secret_string = jsonencode({
    username = aws_db_instance.orders_postgresql.username
    password = aws_db_instance.orders_postgresql.password
    host     = aws_db_instance.orders_postgresql.address
    port     = 5432
    dbname   = aws_db_instance.orders_postgresql.db_name
  })
}

output "catalog_mysql_secret_arn" {
  value = aws_secretsmanager_secret.catalog_mysql.arn
}

output "orders_postgresql_secret_arn" {
  value = aws_secretsmanager_secret.orders_postgresql.arn
}

# --- IAM user for carts DynamoDB access ---

resource "aws_iam_user" "carts_dynamodb" {
  name = "carts-dynamodb-user-${var.student_id}"

  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_iam_access_key" "carts_dynamodb_key" {
  user = aws_iam_user.carts_dynamodb.name
}

resource "aws_iam_user_policy" "carts_dynamodb_policy" {
  name = "carts-dynamodb-access-${var.student_id}"
  user = aws_iam_user.carts_dynamodb.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:DescribeTable"
        ]
        Resource = [
          aws_dynamodb_table.carts.arn,
          "${aws_dynamodb_table.carts.arn}/index/*"
        ]
      }
    ]
  })
}

output "carts_dynamodb_access_key_id" {
  value     = aws_iam_access_key.carts_dynamodb_key.id
  sensitive = true
}

output "carts_dynamodb_secret_access_key" {
  value     = aws_iam_access_key.carts_dynamodb_key.secret
  sensitive = true
}




# --- IRSA for carts service account -> DynamoDB access ---

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

resource "aws_iam_role" "carts_irsa" {
  name = "carts-irsa-role-${var.student_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:retail-app:carts"
            "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_iam_role_policy" "carts_irsa_policy" {
  name = "carts-irsa-dynamodb-${var.student_id}"
  role = aws_iam_role.carts_irsa.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:DescribeTable"
        ]
        Resource = [
          aws_dynamodb_table.carts.arn,
          "${aws_dynamodb_table.carts.arn}/index/*"
        ]
      }
    ]
  })
}

output "carts_irsa_role_arn" {
  value = aws_iam_role.carts_irsa.arn
}
