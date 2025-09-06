#!/bin/bash
# Build script for Docker image automation

set -e 

IMAGE_NAME="react-devops-app"
DOCKER_HUB_USER="jawahar11" 
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
echo "🚀 Starting Docker build process..."
echo "Timestamp: $TIMESTAMP"

BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "Current branch: $BRANCH"
if [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ]; then
TAG="prod-$TIMESTAMP"
REPO_NAME="prod"
echo "📦 Building PRODUCTION image"
elif [ "$BRANCH" = "dev" ]; then
TAG="dev-$TIMESTAMP"
REPO_NAME="dev"
echo "🔧 Building DEVELOPMENT image"
else
TAG="branch-$BRANCH-$TIMESTAMP"
REPO_NAME="dev"
echo "🌿 Building BRANCH image"
fi
# Build the Docker image
echo "Building Docker image: $IMAGE_NAME:$TAG"
docker build -t $IMAGE_NAME:$TAG .

# Tag for Docker Hub
docker tag $IMAGE_NAME:$TAG $DOCKER_HUB_USER/$REPO_NAME:$TAG
docker tag $IMAGE_NAME:$TAG $DOCKER_HUB_USER/$REPO_NAME:latest
echo "✅ Build completed successfully!"
echo "Image tags created:"
echo " - $IMAGE_NAME:$TAG"
echo " - $DOCKER_HUB_USER/$REPO_NAME:$TAG"
echo " - $DOCKER_HUB_USER/$REPO_NAME:latest"
