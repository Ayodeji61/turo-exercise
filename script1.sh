#!/bin/bash

# Variables
imageName="ayodejia/turo"

# Read current version
version=$(cat VERSION | sed 's/v//')  # Removes the 'v' prefix
echo $version

# Increment version
newVersion=$((version + 1))
echo "v$newVersion" > VERSION  # Adds 'v' prefix to the new version

# Tag and registry path
registryPath="${imageName}:v${newVersion}"

# Step 1: Build the Docker image
docker build -t ${imageName}:v${newVersion} . --platform=linux/amd64 --no-cache

# Step 2: Login to Docker registry (You will be prompted for credentials)
docker login

# Step 3: Push the image to the registry
docker push ${imageName}:v${newVersion} 
