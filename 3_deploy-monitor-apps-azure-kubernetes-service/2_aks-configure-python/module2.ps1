Set-PSDebug -Trace 1

# Apply all yaml files to deployment configuration
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Get config from deployment
kubectl get svc aks-config-api-service -w

Set-PSDebug -Trace 0