#!/usr/bin/env bash
# start.sh – open all the port-forwards and apply manifests for local dev
# Usage: ./start.sh
# (Press Ctrl+C to stop)

set -euo pipefail

cleanup() {
  echo -e "\n🛑  Stopping port-forwards…"
  pkill -P $$ || true
}
trap cleanup EXIT

# Apply Kubernetes manifests
echo "📦 Applying manifests..."
kubectl apply -f k8s-manifest/deployment.yaml
kubectl apply -f k8s-manifest/service.yaml
kubectl apply -f k8s-manifest/servicemonitor.yaml

echo "🚀  Starting port-forwards…"

kubectl port-forward svc/todo-api 8000:80 >/dev/null 2>&1 &
echo "🔧 todo-api     → http://localhost:8000"

echo "⏳ Waiting for Grafana to be ready..."
kubectl wait --for=condition=available deployment/monitoring-grafana -n monitoring --timeout=120s
kubectl port-forward -n monitoring deployment/monitoring-grafana 3000:3000 >/dev/null 2>&1 &
echo "📊 Grafana      → http://localhost:3000   (login: admin / prom-operator)"

kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090 >/dev/null 2>&1 &
echo "📈 Prometheus   → http://localhost:9090"

kubectl port-forward svc/argocd-server -n argocd 8080:443 >/dev/null 2>&1 &
echo "🚀 ArgoCD       → https://localhost:8080  (argocd login localhost:8080 --insecure)"

echo -e "\nPress Ctrl+C to stop all port-forwards…"
wait
