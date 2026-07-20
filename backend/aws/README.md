# SHPH Backend AWS Deployment

This folder contains the deployment artifacts for the SHPH backend service.

## Files

- `Dockerfile`: Builds the backend container.
- `ecs-task-def.json`: Example ECS Fargate task definition.
- `ecs-service.json`: Example ECS service configuration.

## Deployment Steps

1. Build the Docker image:
   ```bash
   docker build -t shph-backend:latest .
   ```

2. Push to ECR:
   ```bash
   aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin 888577050475.dkr.ecr.ap-southeast-2.amazonaws.com
   docker tag shph-backend:latest 888577050475.dkr.ecr.ap-southeast-2.amazonaws.com/shph-backend:latest
   docker push 888577050475.dkr.ecr.ap-southeast-2.amazonaws.com/shph-backend:latest
   ```

3. Register the ECS task definition:
   ```bash
   aws ecs register-task-definition --cli-input-json file://aws/ecs-task-def.json
   ```

4. Create or update the ECS service using the task definition.

## Environment variables

- `DATABASE_URL`
- `JWT_SECRET`
- `REDIS_URL`

Use AWS Secrets Manager or Parameter Store for production secrets.
