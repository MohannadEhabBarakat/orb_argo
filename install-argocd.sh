#!/bin/bash
set -e

echo "Creating argocd namespace..."
kubectl create namespace argocd || true

echo "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD components to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

echo "ArgoCD installed successfully!"
echo "You can access the UI by port-forwarding: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Default username is 'admin'."
echo "Initial password can be fetched via: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d; echo"
