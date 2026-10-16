# Zuri Platform — DevOps Capstone

## Overview
Infrastructure, deployment automation, and monitoring for the Zuri application.

## Technologies
- Docker
- Kubernetes (kind)
- Terraform and AWS
- GitHub Actions
- Helm
- Prometheus
- Grafana

## Monitoring

The Node.js backend exposes Prometheus metrics at `/metrics`.

Three Grafana dashboards have been tested:
1. Zuri Monitoring - Target Health
2. Zuri Backend - Response Time
3. Zuri Backend - HTTP Error Rate

## Deploy Grafana

Prerequisites: kubectl, Helm, a running kind cluster, and Prometheus installed in the monitoring namespace.

From the repository root, create the dashboard ConfigMap:

    .\scripts\deploy-grafana-dashboards.ps1

Install or upgrade Grafana:

    helm upgrade --install grafana grafana/grafana --version 10.5.15 --namespace monitoring --kube-context kind-zuri-cluster -f .\monitoring\grafana\values.yaml --wait --timeout 5m

Access Grafana:

    kubectl --context kind-zuri-cluster port-forward -n monitoring service/grafana 3003:80

Open http://localhost:3003 and navigate to Dashboards > Zuri Monitoring.

## Repository Structure
- k8s/ - Kubernetes manifests
- terraform/ - AWS infrastructure configuration
- monitoring/grafana/ - Grafana Helm values and dashboard definitions
- scripts/ - Deployment automation

## Monitoring Status
Prometheus metrics collection and all three Grafana dashboards have been tested successfully on the local kind cluster.
