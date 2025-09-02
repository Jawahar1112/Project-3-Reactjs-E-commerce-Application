#!/bin/bash

set -e 

IMAGE_NAME="react-devops-app"
CONTAINER_NAME="react-app-production"
DOCKER_HUB_USER="jawahar11" 
PORT=80
echo "🚢 Starting deployment process..."
# Determine which image to deploy based on branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
if [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ]; then
REPO_NAME="prod"
echo "📦 Deploying PRODUCTION version"
elif [ "$BRANCH" = "dev" ]; then
REPO_NAME="dev"
echo "🔧 Deploying DEVELOPMENT version"
else
REPO_NAME="dev"
echo "🌿 Deploying from DEV repository"
fi
# Stop and remove existing container if it exists
echo "Stopping existing container..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true
# Pull latest image from Docker Hub
echo "Pulling latest image: $DOCKER_HUB_USER/$REPO_NAME:latest"
docker pull $DOCKER_HUB_USER/$REPO_NAME:latest
# Run new container with health check
echo "Starting new container..."
docker run -d \
--name $CONTAINER_NAME \
--restart unless-stopped \
-p $PORT:80 \
--health-cmd="wget --quiet --tries=1 --spider http://localhost/ || exit 1" \
--health-interval=30s \
--health-timeout=10s \
--health-retries=3 \
$DOCKER_HUB_USER/$REPO_NAME:latest
# Wait for container to be healthy
echo "Waiting for container to be healthy..."
timeout=60
counter=0
while [ $counter -lt $timeout ]; do
health_status=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_NAME 2>
if [ "$health_status" = "healthy" ]; then
echo "✅ Container is healthy and ready!"
break
elif [ "$health_status" = "unhealthy" ]; then
echo "❌ Container is unhealthy"
docker logs $CONTAINER_NAME
exit 1
fi
echo "Container status: $health_status (waiting...)"
sleep 5
counter=$((counter + 5))
done
if [ $counter -ge $timeout ]; then
echo "⚠️ Timeout waiting for container to be healthy"
docker logs $CONTAINER_NAME
exit 1
fi
echo "🎉 Deployment completed successfully!"
echo "Application is running at: http://localhost:$PORT"
echo "Container name: $CONTAINER_NAME"
