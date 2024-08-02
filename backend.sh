#!/bin/bash

# Update package list
sudo apt-get update -y

# Install prerequisites
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up the Docker stable repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Update the package list again
sudo apt-get update -y

# Install Docker
sudo apt-get install -y docker-ce

# Add the current user to the Docker group
# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Print Docker version to verify installation
docker --version


