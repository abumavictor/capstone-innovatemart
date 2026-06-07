resource "aws_iam_user" "dev_user" {
  name = "bedrock-dev-view"

  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_iam_user_policy_attachment" "dev_user_readonly" {
  user       = aws_iam_user.dev_user.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_access_key" "dev_user_key" {
  user = aws_iam_user.dev_user.name
}

resource "aws_s3_bucket_policy" "dev_user_s3_put" {
  bucket = aws_s3_bucket.assets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = aws_iam_user.dev_user.arn }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.assets.arn}/*"
      }
    ]
  })
}
