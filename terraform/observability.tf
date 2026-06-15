# --- CloudWatch Observability EKS Add-on (Section 4.4 - Application Logging) ---

resource "aws_iam_role" "cloudwatch_observability_irsa" {
  name = "cloudwatch-observability-role-${var.student_id}"

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
            "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:amazon-cloudwatch:*"
          }
        }
      }
    ]
  })

  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_observability_policy" {
  role       = aws_iam_role.cloudwatch_observability_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "amazon-cloudwatch-observability"
  addon_version            = "v6.2.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.cloudwatch_observability_irsa.arn

  tags = {
    Project = "karatu-2025-capstone"
  }
}
