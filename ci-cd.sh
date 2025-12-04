#!/bin/bash

# === Local CI/CD Script for Node.js + Minikube ===

set -e

# Define the image name early
IMAGE_NAME=btech:v1.0.0

# 1. Use Minikube Docker daemon
echo "Switching Docker to Minikube environment...."
eval $(minikube docker-env)

# 2. Delete the old Docker image (Cleanup Step)
echo "Attempting to delete old Docker image: $IMAGE_NAME..."
# The '|| true' ensures the script doesn't fail if the image doesn't exist.
docker rmi $IMAGE_NAME 2>/dev/null || true 

# 3. Build Docker image
echo "Building Docker image $IMAGE_NAME..."
docker build -t $IMAGE_NAME .

# 4. Update deployment.yaml image
echo "Updating deployment.yaml with image $IMAGE_NAME..."
sed -i "s|image: .*|image: $IMAGE_NAME|" deployment.yaml

# 5. Apply deployment and service
echo "Applying Kubernetes deployment and service..."
kubectl delete -f deployment.yaml --ignore-not-found
kubectl delete -f service.yaml --ignore-not-found
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# 6. Rollout restart
echo "Restarting deployment..."
kubectl rollout restart deployment node-deployment

# 7. Show pod status
echo "Deployment status:"
kubectl get pods -o wide

# 8. Show service info
echo "Service info:"
kubectl get svc

# 9. Get Service URL for access
SERVICE_NAME=$(kubectl get svc -o jsonpath='{.items[?(@.spec.type=="NodePort")].metadata.name}')
if [ -n "$SERVICE_NAME" ]; then
    echo "Accessing service $SERVICE_NAME..."
    minikube service "$SERVICE_NAME" --url
else
    echo "Warning: Could not find a NodePort service to provide a URL."
fi

echo "CI/CD process completed successfully."