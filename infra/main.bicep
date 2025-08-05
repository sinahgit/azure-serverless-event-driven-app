param baseName string
param environment string = 'dev'
param location string = resourceGroup().location

var prefix = toLower('${baseName}${environment}')
var storageAccountName = '${prefix}sa'
var cosmosAccountName = '${prefix}-cosmos'
var functionAppName = '${prefix}-func'
var eventGridTopicName = '${prefix}-topic'
var appInsightsName = '${prefix}-ai'

module storage 'storage.bicep' = {
  name: 'storage'
  params: {
    storageAccountName: storageAccountName
    location: location
  }
}

module cosmos 'cosmosdb.bicep' = {
  name: 'cosmos'
  params: {
    accountName: cosmosAccountName
    databaseName: 'files'
    containerName: 'rows'
    location: location
  }
}

module eventgrid 'eventgrid.bicep' = {
  name: 'eventgrid'
  params: {
    topicName: eventGridTopicName
    location: location
  }
}

module functionapp 'functionapp.bicep' = {
  name: 'functionapp'
  params: {
    functionAppName: functionAppName
    storageAccountName: storageAccountName
    location: location
    appInsightsName: appInsightsName
    cosmosDbConnString: cosmos.outputs.connectionString
    eventGridTopicEndpoint: eventgrid.outputs.endpoint
    eventGridTopicKey: eventgrid.outputs.key
  }
  dependsOn: [
    storage
    cosmos
    eventgrid
  ]
}

output functionAppName string = functionapp.outputs.functionAppName
output storageAccountName string = storage.outputs.storageAccountName
output eventGridTopicName string = eventGridTopicName
