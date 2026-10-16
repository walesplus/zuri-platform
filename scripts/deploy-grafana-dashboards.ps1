$ErrorActionPreference = "Stop"

kubectl --context kind-zuri-cluster create configmap zuri-grafana-dashboards `
  --namespace monitoring `
  --from-file=./monitoring/grafana/dashboards/zuri-backend-error-rate.json `
  --from-file=./monitoring/grafana/dashboards/zuri-backend-response-time.json `
  --from-file=./monitoring/grafana/dashboards/zuri-monitoring-target-health.json `
  --dry-run=client -o yaml |
kubectl --context kind-zuri-cluster apply -f -

if ($LASTEXITCODE -ne 0) {
    throw "Failed to apply Grafana dashboards ConfigMap."
}

Write-Host "Grafana dashboards ConfigMap applied successfully."
