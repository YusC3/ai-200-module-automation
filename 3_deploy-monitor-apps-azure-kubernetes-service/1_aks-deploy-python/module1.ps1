Set-PSDebug -Trace 1

#region COMPLETE YAML DEVELOPMENT FILES, DEPLOY TO AKS

# 3. Verify deployment
kubectl get deploy,svc

# 4. Check rollout status
kubectl rollout status deploy/aks-api

#endregion

Set-PSDebug -Trace 0