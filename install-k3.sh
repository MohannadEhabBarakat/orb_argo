#!/bin/bash
set -e

echo "======================================"
echo " Automating k3s Installation"
echo "======================================"

echo "Installing k3s..."
# Installs k3s without GPUs since this machine has no GPUs and disables built-in Traefik
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -

echo "Configuring kubectl for the current user..."
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
export KUBECONFIG=~/.kube/config

echo "Waiting for k3s API server to be ready..."
until kubectl get nodes >/dev/null 2>&1; do sleep 2; done

echo "Waiting for k3s node to be ready..."
kubectl wait --for=condition=Ready node --all --timeout=120s

echo "k3s cluster is up and ready!"
kubectl get nodes
