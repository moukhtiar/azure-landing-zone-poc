# Azure Landing Zone POC

A hands-on Azure infrastructure project demonstrating secure hub-and-spoke networking, Terraform-based infrastructure automation, private connectivity, and Azure DevOps CI/CD.

## Overview

This project provisions an Azure network foundation using Terraform and automates infrastructure delivery through an Azure DevOps pipeline.

The implementation combines segmented virtual networks, network security controls, private connectivity to Azure Storage, and a self-hosted Azure DevOps agent virtual machine.

## Architecture

The network foundation uses a hub-and-spoke topology.

![Azure Landing Zone network topology](docs/azure-landing-zone-topology.svg)


### Hub Virtual Network

* **VNet:** `vnet-hub-poc-uaen-01`
* **Address space:** `10.0.0.0/22`
* **AzureFirewallSubnet:** `10.0.0.0/26`
* **AzureBastionSubnet:** `10.0.0.64/26`
* **Shared subnet:** `10.0.1.0/24`
* **Private Endpoint subnet:** `10.0.2.0/26`
* **Agent subnet:** `10.0.2.64/26`

### Spoke Virtual Network

* **VNet:** `vnet-spoke-poc-uaen-01`
* **Address space:** `10.1.0.0/22`
* **Web subnet:** `10.1.0.0/24`
* **Application subnet:** `10.1.1.0/24`

### Connectivity and Security

The Terraform configuration defines:

* Hub-and-spoke virtual network peering.
* Network Security Groups for relevant network segments.
* A NAT Gateway and static public IP for outbound connectivity from the agent subnet.
* A private endpoint for the Azure Storage Blob service used for Terraform state.
* A private DNS zone for Blob private-link resolution, linked to the hub and spoke virtual networks.
* A Linux virtual machine for self-hosted Azure DevOps agent workloads.

> **Deployment note:** The subnet definitions include AzureFirewallSubnet and AzureBastionSubnet. Their presence in the configuration does not, by itself, mean that Azure Firewall or Azure Bastion resources are deployed.

## Technology Stack

* Microsoft Azure
* Terraform
* AzureRM Terraform provider
* Azure DevOps Pipelines
* Azure CLI
* Azure Storage
* Azure Virtual Network
* Azure Private Link and Private DNS

## Repository Structure

```text
.
├── agent-vm.tf
├── azure-pipelines.yml
├── backend.hcl.example
├── locals.tf
├── main.tf
├── nsg.tf
├── outputs.tf
├── private-dns.tf
├── private-endpoint.tf
├── providers.tf
├── variables.tf
├── versions.tf
└── modules/
    └── vnet/
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```

## Terraform Implementation

The Terraform configuration is organized into root-level resource files and a reusable virtual network module.

| File                  | Purpose                                                                  |
| --------------------- | ------------------------------------------------------------------------ |
| `main.tf`             | Root infrastructure configuration and module composition                 |
| `agent-vm.tf`         | Self-hosted agent virtual machine resources                              |
| `nsg.tf`              | Network Security Group configuration                                     |
| `private-endpoint.tf` | Private connectivity to the state Storage Account                        |
| `private-dns.tf`      | Private DNS configuration                                                |
| `providers.tf`        | AzureRM provider configuration                                           |
| `versions.tf`         | Terraform version, provider requirements, and remote backend declaration |
| `variables.tf`        | Input variables and validation                                           |
| `outputs.tf`          | Terraform outputs                                                        |
| `locals.tf`           | Local values                                                             |
| `modules/vnet/`       | Reusable virtual network module                                          |
| `azure-pipelines.yml` | Azure DevOps CI/CD pipeline                                              |
| `backend.hcl.example` | Example remote backend configuration                                     |

The Terraform configuration pins the AzureRM provider to version `4.44.0` and requires Terraform `>= 1.9.0, < 2.0.0`.

## Azure DevOps CI/CD

The pipeline defines three stages.

![Terraform CI/CD workflow](docs/terraform-pipeline-workflow.svg)

### 1. Validate

* Installs the pinned Terraform version.
* Verifies the downloaded Terraform archive against HashiCorp's published SHA-256 checksum.
* Checks Terraform formatting.
* Initializes the configuration without the remote backend.
* Runs `terraform validate`.

### 2. Plan

* Runs on a configured self-hosted agent pool.
* Authenticates to Azure through an Azure DevOps service connection.
* Initializes the remote backend.
* Creates a saved Terraform plan.
* Publishes the binary plan and a readable text representation as pipeline artifacts.

### 3. Approval-Gated Apply

* Runs only after the preceding stages succeed.
* Is restricted to the `main` branch.
* Uses a configured Azure DevOps environment for deployment approval checks.
* Downloads and applies the saved Terraform plan.

The pipeline YAML contains placeholders for environment-specific configuration. These must be replaced with values appropriate to the deploying organization.

## Prerequisites

Before deployment, prepare the following:

1. An Azure subscription with permission to create the required infrastructure.
2. Terraform `1.9.8` or a compatible version within the declared Terraform version constraint.
3. Azure CLI and an Azure DevOps organization and project.
4. An Azure DevOps service connection configured for workload identity federation.
5. A self-hosted Linux agent with network connectivity to the resources it must manage.
6. An existing Azure Storage Account and Blob container for Terraform remote state.
7. Appropriate Azure permissions for both remote state access and infrastructure deployment.
8. An SSH public key for the agent VM administrator.
9. An Azure DevOps environment with approval checks configured for the Apply stage.

The remote state Storage Account and container must exist before Terraform initializes the backend. The self-hosted agent must also be able to resolve and reach the Storage Account's private endpoint when private access is enforced.

## Configuration

### 1. Configure Terraform inputs

Provide the required Terraform inputs through an appropriate local variable file or environment variables.

Required inputs include:

* `owner`
* `costcenter`
* `agent_admin_ssh_public_key`
* `subscription_id`
* `tfstate_storage_account_id`

The state Storage Account resource ID supplied to Terraform must identify the same Storage Account used by the remote backend.

Do not commit environment-specific `.tfvars` files, credentials, private keys, or state files.

### 2. Configure the remote backend

Use `backend.hcl.example` as a reference for the backend configuration.

Create your own local backend configuration containing your existing state resource group, Storage Account, Blob container, and state key. Keep environment-specific backend configuration out of version control.

For Azure Storage authentication, configure the necessary identity and data-plane permissions. This project uses Azure AD-based backend authentication.

### 3. Initialize and validate

From the repository root:

```bash
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
```

For deployment, initialize Terraform with your own backend configuration and authenticated Azure environment.

### 4. Configure Azure DevOps

Update the placeholders in `azure-pipelines.yml` and configure the required pipeline variables.

The pipeline expects these configuration values:

* `subscriptionId`
* `tfstateStorageAccountId`
* `owner`
* `costcenter`
* `agent_admin_ssh_public_key`
* `tfstateResourceGroup`
* `tfstateStorageAccount`
* `tfstateContainer`
* `tfstateKey`

It also requires the Azure DevOps service connection, self-hosted agent pool, and deployment environment configured in the YAML.

Ensure the Azure subscription selected by the service connection matches `subscriptionId`.

## Security Considerations

* Use workload identity federation rather than storing long-lived Azure client secrets in pipeline variables.
* Apply least-privilege access to Azure resources and the remote state container.
* Protect pipeline artifacts because Terraform plans can contain sensitive values.
* Keep private keys, credentials, Terraform state, and local variable files out of version control.
* Restrict approval and deployment permissions for the Apply stage.
* Verify network access to the private state endpoint from the self-hosted agent.
* Review planned infrastructure changes before approving deployment.

## Cleanup

Before destroying infrastructure, inspect resource dependencies and confirm that the resources are not shared with other workloads.

The Terraform state Storage Account may be an existing prerequisite rather than a resource owned by this configuration. Do not delete it as part of cleanup unless you have independently confirmed that it is dedicated to this deployment and that its state is no longer required.

## Validation Status

The Terraform configuration has passed local `terraform validate` and `terraform fmt -check -recursive` checks.

These checks validate Terraform configuration and formatting; they do not establish that a deployment will succeed in every Azure environment. The Azure DevOps pipeline must be configured and tested against the target environment before being considered deployment-ready.
