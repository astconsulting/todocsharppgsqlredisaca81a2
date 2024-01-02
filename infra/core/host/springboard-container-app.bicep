param name string
param location string = resourceGroup().location
param tags object = {}

param environmentId string
param serviceType string = ''

resource app 'Microsoft.App/containerApps@2022-11-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    environmentId: environmentId
    configuration: {
      service: {
        type: serviceType
      }
    }
    template: {
      containers: [
        {
          name: name
          image: serviceType
        }
      ]
    }
  }
}

output serviceName string = app.name
