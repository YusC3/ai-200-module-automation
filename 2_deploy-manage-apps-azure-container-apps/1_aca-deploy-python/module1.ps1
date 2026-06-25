# 1. Create the container app with a system-assigned managed identity and configure registry authentication at create time
Write-Host "STEP 1: Creating and deploying Container App and configuring Managed Identity (at create time)"
az containerapp create `
    --name $env:CONTAINER_APP_NAME `
    --resource-group $env:RESOURCE_GROUP `
    --environment $env:ACA_ENVIRONMENT `
    --image "$env:ACR_SERVER/$env:CONTAINER_IMAGE" `
    --ingress external `
    --target-port $env:TARGET_PORT `
    --env-vars MODEL_NAME=$env:MODEL_NAME `
    --registry-server "$env:ACR_SERVER" `
    --registry-identity system

# 2. Create a secret and reference it from an environment variable
Write-Host ""
Write-Host "STEP 2: Creating api key secret from env var"
az containerapp secret set -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
    --secrets embeddings-api-key=$env:EMBEDDINGS_API_KEY


# 3. Reference the secret from an environment variable
Write-Host ""
Write-Host "STEP 3: Referencing secret through container app and updating"
az containerapp update -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
    --set-env-vars EMBEDDINGS_API_KEY=secretref:embeddings-api-key

# 4. Run the following command to list the revisions to confirm a new revision was created
Write-Host ""
Write-Host "STEP 4: Checking recent secret update"
az containerapp revision list -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP -o table

# ============================================================================
# VERIFY DEPLOYMENT
# ============================================================================
Write-Host "--- VERIFYING DEPLOYMENT ---"

# 1. Retrieve the app FQDN and store the result to a variable
$FQDN = az containerapp show -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP `
    --query properties.configuration.ingress.fqdn -o tsv

Write-Host ""
Write-Host "STEP 1: Get FQDN ($FQDN)"
Write-Output $FQDN

# 2. Check api health
Write-Host ""
Write-Host "STEP 2: Checking Api health"
$response = Invoke-RestMethod -Uri "https://$FQDN/health"
Write-Host $response

# 3. Run the following command to verify the secret is configured by calling the root endpoint
Write-Host ""
Write-Host "STEP 3: Calling endpoint for $FQDN"
Invoke-RestMethod -Uri "https://$FQDN/"

# 4. Run the following command to test the document processing endpoint
Write-Host ""
Write-Host "STEP 4: Testing api core functionality, post request"
$response = Invoke-RestMethod -Uri "https://$FQDN/process" `
    -Method Post `
    -ContentType "text/plain" `
    -Body (Get-Content -Raw document.txt)
Write-Host $response

# 5. Run the following command to review logs for startup and runtime signals
Write-Host ""
Write-Host "STEP 5: Review logs for startup and runtime signals"
az containerapp logs show -n $env:CONTAINER_APP_NAME -g $env:RESOURCE_GROUP