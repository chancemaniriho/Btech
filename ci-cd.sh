#!/bin/bash

# === Local CI/CD Script for Node.js + Minikube (with Auto-Versioning) ===

set -e

# Define the image name using the current timestamp for a unique tag
# Format: btech:YYYYMMDD-HHMMSS
VERSION_TAG=$(date +%Y%m%d-%H%M%S)
IMAGE_NAME="btech:${VERSION_TAG}"

# 1. Use Minikube Docker daemon
echo "Switching Docker to Minikube environment...."
eval $(minikube docker-env)

# 2. Build Docker image with the unique tag
echo "Building Docker image ${IMAGE_NAME}..."
docker build -t $IMAGE_NAME .

# 3. Update deployment.yaml image
echo "Updating deployment.yaml with unique image tag: ${IMAGE_NAME}..."
# Using the new version tag forces Kubernetes to recognize a change.
sed -i "s|image: btech:.*|image: ${IMAGE_NAME}|" deployment.yaml

# 4. Apply deployment and service
# It's better to use 'kubectl apply' which handles creation/updates without explicit deletion.
echo "Applying Kubernetes deployment and service..."
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# 5. Rollout restart
# NOTE: Rollout restart is often unnecessary if the image tag is truly unique (as it is now).
# Kubernetes detects the change in deployment.yaml and initiates the rollout automatically.
echo "Waiting for deployment to roll out with new image..."
kubectl rollout status deployment/node-deployment -w

# 6. Show pod status
echo "Deployment status:"
kubectl get pods -o wide

# 7. Show service info
echo "Service info:"
kubectl get svc

# 8. Get Service URL for access
SERVICE_NAME=$(kubectl get svc -o jsonpath='{.items[?(@.spec.type=="NodePort")].metadata.name}')
if [ -n "$SERVICE_NAME" ]; then
    echo "Accessing service $SERVICE_NAME..."
    minikube service "$SERVICE_NAME" --url
else
    echo "Warning: Could not find a NodePort service to provide a URL."
fi

echo "CI/CD process completed successfully with version ${VERSION_TAG}.";