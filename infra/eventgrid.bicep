param topicName string
param location string = resourceGroup().location

resource topic 'Microsoft.EventGrid/topics@2022-06-15' = {
  name: topicName
  location: location
  properties: {
    inputSchema: 'EventGridSchema'
  }
}

var keys = listKeys(topic.id, topic.apiVersion)

output endpoint string = topic.properties.endpoint
output key string = keys.key1
