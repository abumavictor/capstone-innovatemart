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
