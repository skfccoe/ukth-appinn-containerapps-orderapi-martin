# Generate a random name
name=ca$(cat /dev/urandom | tr -dc '[:lower:]' | fold -w ${1:-5} | head -n 1)

# Set variables for the rest of the demo
name=martinoehleen
resourceGroup=martin-oehleen-rg
location=westeurope
containerAppEnv=${name}-env
logAnalytics=${name}-la
appInsights=${name}-ai
acr=${name}acr


az deployment group create \
  -g $resourceGroup \
  --template-file v1_template.bicep \
  --parameters @v1_parametersbicep.json \
  --parameters \
    ContainerApps_Environment_Name=$containerAppEnv \
    LogAnalytics_Workspace_Name=$logAnalytics \
    AppInsights_Name=$appInsights \
    Container_Registry_Name=$acr 


    az ad sp create-for-rbac \
  --name <SERVICE_PRINCIPAL_NAME> \
  --role "contributor" \
  --scopes /subscriptions/20a184df-3d51-4971-84e0-7c6be4417fbb/resourceGroups/martin-oehleen-rg \
  --sdk-auth


{
"clientId": "1dc56767-8f09-42df-8908-9b5a4cf704cf",
"clientSecret": "A82HR2xgXib4tcHs6KZU_UKJm.DDkr6SZh",
"subscriptionId": "9d655d93-ec56-4eff-879d-53af7b140aab",
"tenantId": "41875f2b-33e8-4670-92a8-f643afbb243a",
"activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
"resourceManagerEndpointUrl": "https://management.azure.com/",
"activeDirectoryGraphResourceId": "https://graph.windows.net/",
"sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
"galleryEndpointUrl": "https://gallery.azure.com/",
"managementEndpointUrl": "https://management.core.windows.net/"
}

spClientid="1dc56767-8f09-42df-8908-9b5a4cf704cf"
spClientSecret="A82HR2xgXib4tcHs6KZU_UKJm.DDkr6SZh"
tenantid="41875f2b-33e8-4670-92a8-f643afbb243a"

acrUrl=$(az acr show -n $acr -g $resourceGroup --query 'loginServer' -o tsv)
acrUsername=$(az acr show -n $acr -g $resourceGroup --query 'name' -o tsv)
acrSecret=$(az acr credential show -n $acr -g $resourceGroup --query passwords[0].value -o tsv)

ghToken=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

repoUrl=https://github.com/skfccoe/ukth-appinn-containerapps-orderapi-martin


az containerapp github-action add \
  --repo-url $repoUrl \
  --context-path "./queuereaderapp/Dockerfile" \
  --branch main \
  --name queuereader \
  --resource-group $resourceGroup \
  --registry-url $acrUrl \
  --registry-username $acrUsername \
  --registry-password $acrSecret \
  --service-principal-client-id $spClientid \
  --service-principal-client-secret $spClientSecret \
  --service-principal-tenant-id $tenantid \
  --token $ghToken