param functionAppName string
param storageAccountName string
param location string = resourceGroup().location
param runtimeVersion string = '~4'
param appInsightsName string
param cosmosDbConnString string
param eventGridTopicEndpoint string
param eventGridTopicKey string

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

var storageKeys = listKeys(storage.id, storage.apiVersion)
var storageConn = 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${storageKeys.keys[0].value};EndpointSuffix=core.windows.net'

resource plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${functionAppName}-plan'
  location: location
  kind: 'FunctionApp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageConn
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: runtimeVersion
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'CosmosDBConnection'
          value: cosmosDbConnString
        }
        {
          name: 'EventGridTopicEndpoint'
          value: eventGridTopicEndpoint
        }
        {
          name: 'EventGridTopicKey'
          value: eventGridTopicKey
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
      ]
    }
  }
}

output functionAppName string = functionApp.name
