#!/bin/bash

# === Local CI/CD Script for Node.js + Minikube ===

set -e

# 1. Use Minikube Docker daemon
echo "Switching Docker to Minikube environment...."
eval $(minikube docker-env)

# 2. Build Docker image
IMAGE_NAME=btech:production
echo "Building Docker image $IMAGE_NAME..."
docker build -t $IMAGE_NAME .

# 3. Update deployment.yaml image
echo "Updating deployment.yaml with image $IMAGE_NAME..."
sed -i "s|image: .*|image: $IMAGE_NAME|" deployment.yaml

# 4. Apply deployment and service
echo "Applying Kubernetes deployment and service..."
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# 5. Rollout restart
echo "Restarting deployment..."
kubectl rollout restart deployment node-deployment

# 6. Show pod status
echo "Deployment status:"
kubectl get pods -o wide

# 7. Show service info
echo "Service info:"
kubectl get svc

# 8. Get Service URL for access (NEW STEP)
SERVICE_NAME=$(kubectl get svc -o jsonpath='{.items[?(@.spec.type=="NodePort")].metadata.name}') # Assumes a NodePort service is created
if [ -n "$SERVICE_NAME" ]; then
    echo "Accessing service $SERVICE_NAME..."
    minikube service "$SERVICE_NAME" --url
else
    echo "Warning: Could not find a NodePort service to provide a URL."
fi

echo "CI/CD process completed successfully."