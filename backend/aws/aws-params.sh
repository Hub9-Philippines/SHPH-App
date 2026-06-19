#!/usr/bin/env bash

# Replace placeholders before running.
export AWS_REGION=ap-southeast-2
export ECR_REPOSITORY=shph-backend
export ECR_ACCOUNT_ID=888577050475
export CLUSTER_NAME=shph-backend-cluster
export SERVICE_NAME=shph-backend-service
export TASK_FAMILY=shph-backend-task

aws ecr create-repository --repository-name ${ECR_REPOSITORY} || true
