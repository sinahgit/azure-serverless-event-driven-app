# Azure Serverless Event-Driven App

This repository contains an example Azure serverless application that processes CSV files uploaded to Azure Blob Storage.

## Architecture

1. **Blob Storage** hosts an `uploads` container where CSV files are uploaded.
2. A **Blob-triggered Azure Function** runs when new files arrive. It parses the CSV, inserts each row into **Azure Cosmos DB**, and sends an event to an **Event Grid** custom topic to notify downstream services.
3. **Bicep** templates in the `infra/` directory deploy all Azure resources.
4. A **GitHub Actions** workflow performs infrastructure provisioning and function deployment.

## Repository Structure

```
.github/workflows/deploy.yml   # CI/CD pipeline
infra/                         # Bicep templates
  main.bicep
  storage.bicep
  cosmosdb.bicep
  eventgrid.bicep
  functionapp.bicep
src/function_app/              # Azure Function code
  __init__.py
  function.json
  requirements.txt
tests/                         # Unit tests
  test_function.py
```

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Bicep CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install)
- [Azure Functions Core Tools](https://learn.microsoft.com/azure/azure-functions/functions-run-local)
- An Azure subscription
- GitHub repository secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`

## Deployment

1. Clone this repository and push changes to `main`.
2. Configure the environment variables in `.github/workflows/deploy.yml` or override them in your workflow.
3. The GitHub Actions workflow will:
   - Authenticate to Azure using `azure/login`.
   - Deploy infrastructure with `az deployment group create` using the Bicep templates.
   - Publish the Azure Function using `func azure functionapp publish`.

## Running Tests

Run unit tests locally with:

```bash
pip install -r src/function_app/requirements.txt pytest
pytest
```

## Clean Up

Delete the resource group to remove all deployed resources:

```bash
az group delete --name <resource-group> --yes --no-wait
```
