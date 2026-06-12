# App of Apps Kubernetes Local Environment

This repository contains the configuration to set up a local development Kubernetes cluster, heavily relying on the ArgoCD App of Apps pattern. 

The environment is built using Minikube on Windows (WSL) and handles complex dependencies through sync waves.

## Prerequisites

- [Minikube](https://minikube.sigs.k8s.io/docs/start/) installed on Windows.
- WSL (Windows Subsystem for Linux) setup.
- `kubectl` configured.

## Cluster Setup

If you haven't started Minikube yet, initialize your environment. From your WSL terminal:

```bash
# Note: minikubes is an alias set up to point to your minikube.exe
minikubes start --driver=docker  --addons=ingress,default-storageclass,storage-provisioner --gpus=all --nodes=3 --listen-address=0.0.0.0
```

To SSH into the minikube node (if needed for debugging):
```bash
minikubes ssh
```

## Step 1: Install ArgoCD

ArgoCD is required as the foundational Continuous Delivery tool to bootstrap the rest of the cluster via the App of Apps pattern.

We have provided a script to install and configure ArgoCD:

```bash
./install-argocd.sh
```

*(If you prefer to install manually)*:
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Step 2: Apply the App of Apps

Once ArgoCD is running, you can bootstrap the entire environment by applying the root application:

```bash
kubectl apply -f ./argo-apps.yaml
```

This root application will automatically sync and deploy the following waves in order:

- **WAVE 0:** Bank-Vaults Operator
- **WAVE 1:** Core Storage & Secrets (PostgreSQL, Vault, Redis)
- **WAVE 1.5:** Secret Bridging (VaultStaticSecret)
- **WAVE 2:** Network & Core Identity (Istio, Authentik)
- **WAVE 3:** Downstream Platforms (MinIO, OpenFGA, Prometheus)
- **WAVE 4:** Visualization, Tools & Code (Grafana, Loki, DCGM, Proxpi, Gitea)

## Domain Configuration

We use `*.localhost` for local routing to our services via Istio. You do not need to modify your host machine's `/etc/hosts` file since `localhost` resolves locally.
