#region BUILD AND DEPLOY IMAGE IN AZURE

# 1. Build and push image to registry in Container Registry
Write-Host "Building image and pushing to registry"
az acr build `
    --registry $env:ACR_NAME `
    --image inference-api:v1.0.0 `
    ./api

#endregion

#region VERIFY IMAGE IN REGISTRY

# 1. List all repositories in registry
Write-Host ""
Write-Host "Repository list for Container Registry: $env:ACR_NAME"
az acr repository list --name $env:ACR_NAME --output table

# 2. List tags for the inference-api repository
Write-Host ""
Write-Host "Listing tags for Repository: inference-api "
az acr repository show-tags `
    --name $env:ACR_NAME `
    --repository inference-api `
    --output table

# 3. View detailed manifest information, including the SHA-256 digest
Write-Host ""
Write-Host "detailed manifest information, including the digest for inference-api"
az acr manifest list-metadata `
    --registry $env:ACR_NAME `
    --name inference-api `
    --output table

#endregion

#region RUN THE IMAGE

# 1. Verify the Flask application loads correctly in the container
Write-Host ""
Write-Host "Verifying Flask application loads"
az acr run `
    --registry $env:ACR_NAME `
    --cmd "$env:ACR_NAME.azurecr.io/inference-api:v1.0.0 python -c 'from app import app'" `
    /dev/null

#endregion

#region BUILD WITH DIFFERENT TAG

# 1. Build the image again with a new version tag
$env:NEWVERSIONTAG = "v1.1.0"
Write-Host ""
Write-Host "Build the image again with a new version tag: $env:NEWVERSIONTAG"
az acr build `
    --registry $env:ACR_NAME `
    --image inference-api:$env:NEWVERSIONTAG `
    ./api

# 2. List all tags and see both versions
Write-Host ""
Write-Host "Listing all tags for inference-api"
az acr repository show-tags `
    --name $env:ACR_NAME `
    --repository inference-api `
    --output table

#endregion

#region VIEW BUILD HISTORY AND LOCK PROD. IMAGE

# 1. View history of all build ran
Write-Host ""
Write-Host "History of all builds ran for Container Registry: $env:ACR_NAME"
az acr task list-runs `
    --registry $env:ACR_NAME `
    --output table

# 2. Lock v1.0.0 image
$env:LOCKVERSION = "v1.0.0"
Write-Host ""
Write-Host "Locking specific image verison: inference-api:$env:LOCKVERSION"
az acr repository update `
    --name $env:ACR_NAME `
    --image inference-api:$env:LOCKVERSION `
    --write-enabled false

# 3. Verify image locked
Write-Host ""
Write-Host "Verify image is locked at '$env:LOCKVERSION'"
az acr repository show `
    --name $env:ACR_NAME `
    --image inference-api:$env:LOCKVERSION