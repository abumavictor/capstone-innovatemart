resource "aws_dynamodb_table" "carts" {
  name         = "carts-bedrock-${var.student_id}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
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
