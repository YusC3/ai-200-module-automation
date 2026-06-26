# This is a compiled list of the necessary providers and extensions needed to complete the AI-200 cert paths!

Set-PSDebug -Trace 1
az extension add --name containerapp
az extension add --name log-analytics

az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.CognitiveServices
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace Microsoft.DocumentDB
az provider register --namespace Microsoft.DBforPostgreSQL

Set-PSDebug -Trace 0