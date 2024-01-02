param name string
param location string = resourceGroup().location
param tags object = {}

param applicationInsightsName string
param containerAppsEnvironmentName string
param containerRegistryName string
param imageName string = ''
param serviceName string = 'api'
param redisServiceName string = 'redis'
param postgresServiceName string = 'postgres'

module app '../core/host/container-app.bicep' = {
  name: '${serviceName}-container-app-module'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    containerCpuCoreCount: '1.0'
    containerMemory: '2.0Gi'
    env: [
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsights.properties.ConnectionString
      }
    ]
    imageName: !empty(imageName) ? imageName : 'nginx:latest'
    targetPort: 80
    serviceBinds: [
      {
        serviceId: redis.id
        name: redis.name
      }
      {
        serviceId: postgres.id
        name: postgres.name
      }
    ]
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource redis 'Microsoft.App/containerApp@2022-11-01-preview' existing = {
  name: redisServiceName
}

resource postgres 'Microsoft.App/containerApp@2022-11-01-preview' existing = {
  name: postgresServiceName
}

output SERVICE_API_IDENTITY_PRINCIPAL_ID string = app.outputs.identityPrincipalId
output SERVICE_API_NAME string = app.outputs.name
output SERVICE_API_URI string = app.outputs.uri
output SERVICE_API_IMAGE_NAME string = app.outputs.imageName
