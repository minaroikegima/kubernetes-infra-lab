# Kubernetes Infrastructure Lab

![CI](https://github.com/minaroikegima/kubernetes-infra-lab/actions/workflows/ci.yml/badge.svg)

A container orchestration platform using Kubernetes and Docker to support scalable application deployments with built-in monitoring.

## What This Project Does
- Runs a local Kubernetes cluster using kind
- Deploys containerized applications using Helm charts
- Implements service discovery and container networking
- Auto-scales applications based on CPU and memory usage
- Monitors the cluster with Prometheus and Grafana

## Technologies Used
- Kubernetes
- Docker
- Helm
- kind (local cluster)
- Prometheus
- Grafana

## Architecture Diagram
```
┌─────────────────────────────────────────────────────────┐
│                  Kubernetes Cluster                      │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │              app Namespace                       │   │
│  │                                                 │   │
│  │  ┌──────────┐    ┌──────────┐    ┌──────────┐  │   │
│  │  │  Pod 1   │    │  Pod 2   │    │  Pod 3   │  │   │
│  │  │  nginx   │    │  nginx   │    │  nginx   │  │   │
│  │  └────┬─────┘    └────┬─────┘    └────┬─────┘  │   │
│  │       └───────────────┴───────────────┘        │   │
│  │                       │                         │   │
│  │              ┌────────▼────────┐                │   │
│  │              │    Service      │                │   │
│  │              │  LoadBalancer   │                │   │
│  │              └────────┬────────┘                │   │
│  └───────────────────────┼─────────────────────────┘   │
│                          │                             │
│  ┌───────────────────────┼─────────────────────────┐   │
│  │         monitoring Namespace                     │   │
│  │  Prometheus ── Grafana ── Alertmanager           │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Control Plane: API Server │ etcd │ Scheduler   │   │
│  │  Worker Nodes:  kubelet │ kube-proxy │ CNI      │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## How to Use

### Step 1 - Create Cluster
```bash
chmod +x scripts/cluster-setup.sh
./scripts/cluster-setup.sh
```

### Step 2 - Deploy Application
```bash
helm upgrade --install my-app helm/charts/app \
  --namespace app \
  --create-namespace
```

### Step 3 - Verify Deployment
```bash
kubectl get pods -n app
kubectl get services -n app
```

## Key Features
| Feature | Description |
|---------|-------------|
| Auto-scaling | HPA scales pods based on CPU/memory |
| Rolling updates | Zero downtime deployments |
| Health checks | Liveness and readiness probes |
| Service discovery | CoreDNS for internal DNS |
| Monitoring | Prometheus metrics per pod |
