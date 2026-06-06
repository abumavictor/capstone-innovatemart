# InnovateMart Capstone - Project Bedrock

## Overview
Production-grade microservices deployment on AWS EKS for InnovateMart Inc.

## Architecture
- VPC: project-bedrock-vpc (us-east-1, 2 AZs, public + private subnets)
- EKS Cluster: project-bedrock-cluster (v1.34)
- Application Namespace: retail-app
- S3 Bucket: bedrock-assets-alt-soe-025-5344
- Lambda: bedrock-asset-processor
- IAM Developer User: bedrock-dev-view

## Prerequisites
- AWS CLI configured
- Terraform >= 1.0
- kubectl
- helm

## Deployment Guide

### 1. Trigger the Pipeline
Push to main branch to trigger terraform apply:
git push origin main

Pull requests trigger terraform plan only.

### 2. Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name project-bedrock-cluster

### 3. Apply Kubernetes manifests
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/rbac.yaml
kubectl apply -f kubernetes/ingress.yaml

### 4. Access the Retail Store
After deployment, get the ALB URL:
kubectl get ingress -n retail-app

### 5. Generate Grading Output
cd terraform
terraform output -json > ../grading.json

## Resource Tagging
All resources tagged with: Project = karatu-2025-capstone

## CI/CD
- Pull Request: triggers terraform plan
- Merge to Main: triggers terraform apply