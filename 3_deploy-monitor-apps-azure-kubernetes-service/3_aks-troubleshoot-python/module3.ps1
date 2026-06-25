Set-PSDebug -Trace 1

#region TROUBLESHOOT DEPLOYMENT
Write-Host "TROUBLESHOOT DEPLOYMENT"

# 1. Verify the pod is running in the namespace
kubectl get pods -n aks-troubleshoot

# 2. Verify the Service has endpoints
kubectl get endpointslices -l kubernetes.io/service-name=api-service -n aks-troubleshoot

# 3. Test Connectivity 
Read-Host "Copy and run this command in a new terminal, then press enter 'kubectl port-forward service/api-service 8080:80 -n aks-troubleshoot'"
# kubectl port-forward service/api-service 8080:80 -n aks-troubleshoot

# 4. Test connection through /health endpoint
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Invoke-RestMethod http://localhost:8080/healthz"

#endregion

#region DIAGNOSE A LABEL MISMATCH
Write-Host "DIAGNOSE A LABEL MISMATCH"

# 1. Create a label mismatch error
kubectl apply -f k8s/label-mismatch-service.yaml -n aks-troubleshoot

# 2. Verify the pod is still running
kubectl get pods --show-labels -n aks-troubleshoot

# 3. Check the Service endpoint slices
kubectl get endpointslices -l kubernetes.io/service-name=api-service -n aks-troubleshoot

# 4. View Service details
kubectl describe service api-service -n aks-troubleshoot

# 5. Open Service config in an editor 
kubectl edit service api-service -n aks-troubleshoot

Read-Host "Edit the document in the editor of choice, then hit enter"

# 7. Verify endpoint slice addresses are restored
kubectl get endpointslices -l kubernetes.io/service-name=api-service -n aks-troubleshoot

#endregion
#region DIAGNOSE A CRASHLOOPBACKOFF
Write-Host "DIAGNOSE A CRASHLOOPBACKOFF"

# 1. Removes the required API_KEY environment variable
kubectl apply -f k8s/crashloop-deployment.yaml -n aks-troubleshoot

# 2. Watch the pod status
Read-Host "Copy and run this command in a new terminal, then press enter 'kubectl get pods -n aks-troubleshoot -w'"
#kubectl get pods -n aks-troubleshoot -w

# 3. Check the pod logs for the error message
kubectl logs -l app=api -n aks-troubleshoot

# 4. ix the issue by editing the Deployment to add the API_KEY environment variable
kubectl edit deployment api-deployment -n aks-troubleshoot

Read-Host "Edit the api-deploment.yaml file, then press any key"

# 5. Check pod status
Read-Host "Copy and run this command in a new terminal, then press enter 'kubectl get pods -n aks-troubleshoot -w'"
#kubectl get pods -n aks-troubleshoot -w

#endregion
#region DIAGNOSE A READINESS PROBE FAILURE
Write-Host "DIAGNOSE A READINESS PROBE FAILURE"

# 1. Run the following command to introduce a readiness probe failure
kubectl apply -f k8s/probe-failure-deployment.yaml -n aks-troubleshoot

# 2. Check pod status (you should see two pods)
kubectl get pods -n aks-troubleshoot

# 3. Check for probe failure events
kubectl get events -n aks-troubleshoot --field-selector reason=Unhealthy

# 4. Fix the readiness probe by editing the Deployment to correct the path
kubectl edit deployment api-deployment -n aks-troubleshoot

Read-Host "Edit the api-deploment.yaml file, then press any key"

# 5. Verify the new pod becomes ready and the old pod terminates
kubectl get pods -n aks-troubleshoot

#endregion
#region VERIFY END-TO-END CONNECTIVITY
Write-Host "VERIFY END-TO-END CONNECTIVITY"

# 1. Use port-forward to access the Service
Read-Host "Run this command in a new terminal then press enter 'kubectl port-forward service/api-service 8080:80 -n aks-troubleshoot'"
# kubectl port-forward service/api-service 8080:80 -n aks-troubleshoot

# 2. Test all endpoints
# PowerShell
Start-Process powershell -ArgumentList "-NoExit", "-Command",  "Invoke-RestMethod http://localhost:8080/healthz"
Start-Process powershell -ArgumentList "-NoExit", "-Command",  "Invoke-RestMethod http://localhost:8080/readyz"
Start-Process powershell -ArgumentList "-NoExit", "-Command",  "Invoke-RestMethod http://localhost:8080/api/info"

# 3. Check the pod logs to see the requests
kubectl logs -l app=api -n aks-troubleshoot
#endregion

Set-PSDebug -Trace 0