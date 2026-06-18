#region CREATE RESOURCES IN AZURE

# 7. Verify endpoint available
Invoke-RestMethod "$env:CONTAINER_APP_URL/"
#endregion

#region CONFIGURE AUTOSCALING

# 1. Update the container app with an HTTP scale rule

az containerapp update `
    --name $env:CONTAINER_APP_NAME `
    --resource-group $env:RESOURCE_GROUP `
    --min-replicas 0 `
    --max-replicas 10 `
    --scale-rule-name http-scaling `
    --scale-rule-type http `
    --scale-rule-http-concurrency 10

# 2. Verify the scale rule is configured
az containerapp show `
    --name $env:CONTAINER_APP_NAME `
    --resource-group $env:RESOURCE_GROUP `
    --query "properties.template.scale"

#endregion

#region GENERATE LOAD AND OBSERVE SCALING
# 1. Navigate to the client directory
Set-Location .\client

# 2. Create python env
#python -m venv .venv 
Write-Host "Use this command to create a python environment: python -m venv .venv"
Read-Host "Press enter to continue: "


# 3. Activate python env
#.\.venv\Scripts\Activate.ps1
Write-Host "Use this command to activate python environment: .\.venv\Scripts\Activate.ps1"
Read-Host "Press enter to continue: "

# 4. Install requirements for project
pip install -r requirements.txt

# 5. Run python application
#python app.py
Write-Host "Run application with this command: python app.py"
Read-Host "Press enter to continue: "

#endregion

#region CONFIGURE SCALE RULES USING YAML

# 1. Export app configuration to YAML
az containerapp show `
    --name $env:CONTAINER_APP_NAME `
    --resource-group $env:RESOURCE_GROUP `
    --output yaml > app-config.yaml

# 2. Update YAML file (manually).
Read-Host "Press enter after editing the YAML file: "

# 3. After YAML file update, update app configuration
az containerapp update `
    --name $env:CONTAINER_APP_NAME `
    --resource-group $env:RESOURCE_GROUP `
    --yaml app-config.yaml

# 4. Verify app configuration update
az containerapp show `
    --name $env:CONTAINER_APP_NAME `
    --resource-group $env:RESOURCE_GROUP `
    --query "properties.template.scale"

#endregion
