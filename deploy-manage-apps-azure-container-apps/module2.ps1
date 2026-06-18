#region VERIFY RESOURCE DEPLOYMENT AND UP

# 7. Get app FQDN
$FQDN = az containerapp show -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
    --query properties.configuration.ingress.fqdn -o tsv

Write-Output $FQDN

# 8. Call default endpoint and verify app is running
$uri = "https://$FQDN/"
Invoke-RestMethod -Uri $uri
Write-Host "URI: $uri"

#endregion

#region DIAGNOSE A MISSING ENV VARIABLE

# 1. Update the container app to remove the MODEL_NAME environment variable
Write-Host "Removing MODEL_NAME env var from container app and updating..."
az containerapp update -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
    --remove-env-vars MODEL_NAME

# 2. List revisions to confirm a new revision was created
az containerapp revision list -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP -o table

# 3. Check the root endpoint to observe the symptom from the API consumer's perspective
Write-Host "Checking customer endpoint: $env:URI"
(Invoke-RestMethod -Uri $uri).model

# 4. Diagnose the root cause by viewing the container app's configuration
Write-Host "Display app configuration"
az containerapp show -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
    --query "properties.template.containers[0].env" -o table

# 5. Add MODEL_NAME env var back
Write-Host "Adding MODEL_NAME back to fix issue"
az containerapp update -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
    --set-env-vars MODEL_NAME=$env:MODEL_NAME

# 6. Verifying fix
(Invoke-RestMethod -Uri $uri ).model

#endregion

#region DIAGNOSE AN INGRESS CONFIGURATION ISSUE

# 1. Update app configuration to target port 3000
az containerapp ingress update -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
    --target-port 3000

# 2. Test app health through api/health endpoint
Invoke-RestMethod -Uri "https://$FQDN/health"

# 3. Show YAML file for app configuration
az containerapp show -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
    --query "properties.configuration.ingress" -o yaml

# 4. Display app logs
az containerapp logs show -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP

# 5. Update the app configuration to target port 8000
az containerapp ingress update -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
    --target-port 8000

# 6. Test, again, app health through api/health endpoint
Invoke-RestMethod -Uri "https://$FQDN/health"

#endregion

#region QUERY LOG ANALYTICS FOR HISTORICAL TROUBLESHOOTING

# 1. Get ID for log retrieval
$WORKSPACE_ID = az containerapp env show -n $env:ACA_ENVIRONMENT -g $env:RESOURCE_GROUP `
    --query properties.appLogsConfiguration.logAnalyticsConfiguration.customerId -o tsv

Write-Output "Workspace ID: $WORKSPACE_ID"

# 2. Using Azure Monitor, query logs for the customerId (workspace_ID)
az monitor log-analytics query -w $WORKSPACE_ID `
    --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == '$env:CONTAINER_APP_NAME' | project TimeGenerated, Log_s | order by TimeGenerated desc | take 20" `
    -o table

# 3.  Using Azure Monitor, query logs that contain 'error' for the customerId (workspace_ID)
az monitor log-analytics query -w $WORKSPACE_ID `
    --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == '$env:CONTAINER_APP_NAME' and Log_s contains 'error' | order by TimeGenerated desc | take 20" `
    -o table

#endregion

