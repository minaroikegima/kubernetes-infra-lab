#!/usr/bin/env bash
# Kubernetes Infrastructure Lab - Cluster Setup Script
# Usage: ./scripts/cluster-setup.sh

set -euo pipefail

CLUSTER_NAME="infra-lab"
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()   { echo -e "${GREEN}[OK]${NC}    $*"; }
error(){ echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

echo ""
echo "════════════════════════════════════════════"
echo "  Kubernetes Infrastructure Lab Setup"
echo "════════════════════════════════════════════"
echo ""

# Check prerequisites
check_prerequisites() {
  log "Checking prerequisites..."
  command -v docker &>/dev/null || error "Docker is required"
  command -v kind   &>/dev/null || error "kind is required"
  command -v kubectl &>/dev/null || error "kubectl is required"
  command -v helm   &>/dev/null || error "helm is required"
  docker info &>/dev/null || error "Docker daemon is not running"
  ok "All prerequisites satisfied"
}

# Create kind cluster
create_cluster() {
  if kind get clusters 2>/dev/null | grep -q "$CLUSTER_NAME"; then
    log "Cluster '$CLUSTER_NAME' already exists — skipping"
    return
  fi

  log "Creating kind cluster: $CLUSTER_NAME"
  cat <<KINDEOF | kind create cluster --name "$CLUSTER_NAME" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 8080
        protocol: TCP
      - containerPort: 443
        hostPort: 8443
        protocol: TCP
  - role: worker
  - role: worker
KINDEOF
  ok "Cluster '$CLUSTER_NAME' created"
}

# Create namespaces
create_namespaces() {
  log "Creating namespaces..."
  kubectl apply -f manifests/namespaces/namespaces.yaml
  ok "Namespaces created"
}

# Install Nginx Ingress
install_ingress() {
  log "Installing Nginx Ingress Controller..."
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
  log "Waiting for Ingress Controller to be ready..."
  kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=120s
  ok "Nginx Ingress Controller ready"
}

# Deploy application with Helm
deploy_app() {
  log "Deploying application with Helm..."
  helm upgrade --install my-app helm/charts/app \
    --namespace app \
    --create-namespace \
    --wait \
    --timeout 120s
  ok "Application deployed successfully"
}

# Print summary
print_summary() {
  echo ""
  echo "════════════════════════════════════════════"
  echo "  Cluster Ready!"
  echo "════════════════════════════════════════════"
  echo ""
  kubectl get nodes
  echo ""
  kubectl get pods -n app
  echo ""
  echo "  Access the app:"
  echo "  kubectl port-forward svc/my-app-svc 8080:80 -n app"
  echo "  Then visit: http://localhost:8080"
  echo ""
}

# Run all functions
check_prerequisites
create_cluster
create_namespaces
install_ingress
deploy_app
print_summary
