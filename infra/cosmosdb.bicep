param accountName string
param databaseName string = 'files'
param containerName string = 'rows'
param location string = resourceGroup().location

resource account 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' = {
  name: accountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-05-15' = {
  name: '${account.name}/${databaseName}'
  properties: {
    resource: {
      id: databaseName
    }
    options: {}
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-05-15' = {
  name: '${account.name}/${database.name}/${containerName}'
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: ['/id']
        kind: 'Hash'
      }
    }
    options: {}
  }
}

output connectionString string = listConnectionStrings(account.id, account.apiVersion).connectionStrings[0].connectionString
