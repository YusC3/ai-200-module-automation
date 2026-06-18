#region CREATE WEB APP

# 1. Create and configure Web App
Write-Host "Creating Web App $env:APP_NAME from ACR image"
az webapp create `
    --resource-group $env:RESOURCE_GROUP `
    --plan $env:APP_PLAN `
    --name $env:APP_NAME `
    --container-image-name "$($env:ACR_NAME).azurecr.io/docprocessor:v1"

# 2. Enable a system-assigned managed identity on the web app
Write-Host "Assigning system-managed identity to $env:APP_NAME"
az webapp identity assign `
    --resource-group $env:RESOURCE_GROUP `
    --name $env:APP_NAME

#endregion

#region ASSIGN ACRPULL ROLE TO WEB APP

# 1. Retrieve principal ID for Web App
$PRINCIPAL_ID = az webapp identity show `
    --resource-group $env:RESOURCE_GROUP `
    --name $env:APP_NAME `
    --query principalId `
    --output tsv

Write-Host "Principal ID: $PRINCIPAL_ID"

# 2. Retrieve ID for Azure Container Registry
$ACR_ID = az acr show `
    --resource-group $env:RESOURCE_GROUP `
    --name $env:ACR_NAME `
    --query id `
    --output tsv

Write-Host "ACR ID: $ACR_ID"

# 3. Assign the AcrPull role to the web app
Write-Host "Assigning AcrPull role to $env:APP_NAME"
az role assignment create `
    --assignee $PRINCIPAL_ID `
    --scope $ACR_ID `
    --role AcrPull

# 4. Configure the web app to use managed identity for registry authentication
Write-Host "Configuring ACR authentication via managed identity"
az webapp config set `
    --resource-group $env:RESOURCE_GROUP `
    --name $env:APP_NAME `
    --acr-use-identity true `
    --acr-identity [system]

# 5. Run the following command to update the container settings to use the registry with managed identity
Write-Host "Updating container registry settings"
az webapp config container set `
    --resource-group $env:RESOURCE_GROUP `
    --name $env:APP_NAME `
    --container-image-name "$($env:ACR_NAME).azurecr.io/docprocessor:v1" `
    --container-registry-url "https://$($env:ACR_NAME).azurecr.io"

#endregion

#region CONFIGURE RUNTIME SETTINGS AND ENABLE LOGGING

# 1. Configure the container port
Write-Host "Setting container port to $env:PORT"
$env:PORT = 80
az webapp config appsettings set `
    --resource-group $env:RESOURCE_GROUP `
    --name $env:APP_NAME `
    --settings WEBSITES_PORT=$env:PORT

# 2. Enable persistent storage for processed documents
Write-Host "Enabling persistent storage"
az webapp config appsettings set `
    --resource-group $env:RESOURCE_GROUP `
    --name $env:APP_NAME `
    --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=true

# 3. Enable always-on
Write-Host "Enabling Always On"
az webapp config set `
    --resource-group $env:RESOURCE_GROUP `
    --name $env:APP_NAME `
    --always-on true

# 4. Enable container logging
Write-Host "Enabling container logging to filesystem"
az webapp log config `
    --resource-group $env:RESOURCE_GROUP `
    --name $env:APP_NAME `
    --docker-container-logging filesystem

#endregion

#region VERIFY DEPLOYMENT

# 1. Retrieve the web app host name
$APP_URL = az webapp show `
    --resource-group $env:RESOURCE_GROUP `
    --name $env:APP_NAME `
    --query defaultHostName `
    --output tsv

Write-Host "Application URL: https://$APP_URL"

#endregion

#region TEST API ENDPOINT

# 1. Submit the document.txt file included in the project to the processing endpoint
$body = Get-Content -Raw -Path "document.txt"
Invoke-RestMethod -Method Post -Uri "https://$APP_URL/process" -ContentType "text/plain" -Body $body | ConvertTo-Json -Depth 10

# 2. List all processed documents
Invoke-RestMethod -Uri "https://$APP_URL/documents" | ConvertTo-Json -Depth 10

#endregion

#region STREAM CONTAINER LOGS

# 1. View real-time logs
Write-Host "Logs from $env:APP_NAME : "
az webapp log tail `
    --resource-group $env:RESOURCE_GROUP `
    --name $env:APP_NAME

Start-Sleep 10 # runs live stream logs for 10 seconds, then exit from that command
Stop-Job $job

#endregion

#region INSPECT DIAGNOSTIC CONSOLE

# 1. Print the SCM (Kudu) URL
Write-Host "Kudu URL: https://$($env:APP_NAME).scm.azurewebsites.net"

#endregion

#region VIEW APP SETTINGS

# 1. List Web App settings
Write-Host "Web App Settings: "
az webapp config appsettings list `
    --resource-group $env:RESOURCE_GROUP `
    --name $env:APP_NAME `
    --output table

#endregion