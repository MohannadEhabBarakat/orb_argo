#!/bin/bash
set -e

echo "======================================"
echo " Nuking k3s Cluster"
echo "======================================"

if [ -f /usr/local/bin/k3s-uninstall.sh ]; then
    echo "Running official k3s uninstall script..."
    /usr/local/bin/k3s-uninstall.sh
else
    echo "Official k3s uninstall script not found at /usr/local/bin/k3s-uninstall.sh."
    echo "If k3s was not installed or already uninstalled, you can ignore this."
fi

echo "Cleaning up local kubeconfig..."
rm -f ~/.kube/config

echo "Cleaning up local-path provisioner storage..."
rm -rf /var/lib/rancher/k3s/storage/

echo "Cluster nuked successfully!"
