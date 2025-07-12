#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Building and Pushing Docker Image ---"

# Ensure Terraform is initialized and outputs are available
echo "Running terraform init and apply to ensure outputs are up-to-date..."
# (cd terraform && terraform init -upgrade && terraform apply -auto-approve)

# Get Terraform outputs
echo "Retrieving Terraform outputs..."
PROJECT_REGION=$(terraform -chdir=terraform output -raw project_region)
PROJECT_ID=$(terraform -chdir=terraform output -raw project_id)
REPOSITORY_ID=$(terraform -chdir=terraform output -raw repository_id)

# Construct the full image name
IMAGE_NAME="${PROJECT_REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_ID}/sveltekit-app:latest"
echo "Image name: ${IMAGE_NAME}"

# Build the Docker image
echo "Building Docker image..."
# The build context is the 'app' directory, where the Dockerfile and source code reside.
docker build -t "${IMAGE_NAME}" -f app/Dockerfile ./app

# Push the Docker image to Artifact Registry
echo "Pushing Docker image to Artifact Registry..."
docker push "${IMAGE_NAME}"

echo "--- Docker Image Build and Push Complete ---"
echo "Image pushed: ${IMAGE_NAME}"
