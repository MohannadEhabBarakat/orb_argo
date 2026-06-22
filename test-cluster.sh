#!/bin/bash

./k3s-uninstall.sh
./install-k3.sh
./install-argocd.sh

kubectl apply -f ./argo-apps.yaml

echo "Waiting for CRD..."
until kubectl get crd vaults.vault.banzaicloud.com >/dev/null 2>&1; do sleep 5; done

echo "Waiting for vault instance..."
until kubectl get vault vault -n vault-system >/dev/null 2>&1; do sleep 5; done

echo "Patching vault with example secrets..."
kubectl patch vault vault -n vault-system --type=merge --patch-file manifests/vault/example_vault_sec.yaml

echo "Setting up Let's Encrypt Cloudflare API token..."
cp cf-token-example.txt cf-token.txt
kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic cloudflare-api-token-secret \
  --from-literal=api-token="$(cat cf-token.txt)" \
  -n cert-manager \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Waiting for 2 minutes to allow waves 0, 1, 2, 3 to deploy and initialize..."
sleep 120

for ns in vault-system cert-manager database authentik monitoring; do
  echo "=== $ns ==="
  kubectl get pods -n $ns
done

echo "Checking if redis secret synced..."
kubectl get vaultstaticsecrets -n database
