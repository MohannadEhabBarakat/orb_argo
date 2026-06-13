# App of Apps Kubernetes Local Environment

This repository contains the configuration to set up a local development Kubernetes cluster, heavily relying on the ArgoCD App of Apps pattern. 

The environment is built using k3s and handles complex dependencies through sync waves.

## Prerequisites

- Linux environment (or Windows Subsystem for Linux - WSL).
- `kubectl` configured.

## Cluster Setup

We provide a script to automate the installation of k3s. From your terminal, run:

```bash
chmod +x install-k3.sh
./install-k3.sh
```

*(If you prefer to install manually)*:
```bash
curl -sfL https://get.k3s.io | sh -
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
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
kubectl apply --server-side --force-conflicts -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Accessing the ArgoCD UI

Once ArgoCD is installed, you can access its UI by port-forwarding the server to your local machine:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open `https://localhost:8080` in your browser.
- **Username:** `admin`
- **Password:** Run the following command to retrieve your initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
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
- **WAVE 5:** Dashboard

## Domain Configuration

We use `*.localhost` for local routing to our services via Istio. You do not need to modify your host machine's `/etc/hosts` file since `localhost` resolves locally.
