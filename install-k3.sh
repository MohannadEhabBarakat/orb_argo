#!/bin/bash
set -e

echo "======================================"
echo " Automating k3s Installation"
echo "======================================"

echo "Installing k3s..."
# Installs k3s without GPUs since this machine has no GPUs
curl -sfL https://get.k3s.io | sh -

echo "Configuring kubectl for the current user..."
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
export KUBECONFIG=~/.kube/config

echo "Waiting for k3s node to be ready..."
sleep 5 # Give it a few seconds to start registering
kubectl wait --for=condition=Ready node --all --timeout=120s

echo "k3s cluster is up and ready!"
kubectl get nodes
