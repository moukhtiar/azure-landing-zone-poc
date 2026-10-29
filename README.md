# ☁️ Azure Landing Zone POC

<p align="left">
  <img src="https://img.shields.io/badge/Microsoft_Azure-0078D4?style=flat&logo=microsoftazure&logoColor=white" alt="Microsoft Azure">
  <img src="https://img.shields.io/badge/Terraform-844FBA?style=flat&logo=terraform&logoColor=white" alt="Terraform">
  <img src="https://img.shields.io/badge/Azure_DevOps-0078D7?style=flat&logo=azuredevops&logoColor=white" alt="Azure DevOps">
  <img src="https://img.shields.io/badge/Git-F05032?style=flat&logo=git&logoColor=white" alt="Git">
  <img src="https://img.shields.io/badge/PowerShell-5391FE?style=flat&logo=powershell&logoColor=white" alt="PowerShell">
</p>

A hands-on Microsoft Azure Landing Zone proof of concept focused on secure network foundations, Terraform-b
ased infrastructure management, controlled CI/CD workflows, and progressive cloud security hardening.

The project follows an evidence-driven engineering approach:

**Implement → Validate → Document → Review → Improve**

Each stage builds on the previous one, with implementation status and known limitations documented explicitly.

> **Project scope:** This is a phased proof of concept (POC), not a claim that every capability of a production Azure Landing Zone has been implemented. Completed work, ongoing activities, and planned capabilities are distinguished throughout this repository.

---

## 📊 Project Status

| Area                                        | Current status                                                |
| ------------------------------------------- | ------------------------------------------------------------- |
| Cloud platform                              | Microsoft Azure                                               |
| Azure region                                | UAE North (`uaenorth`)                                        |
| Infrastructure as Code                      | Terraform                                                     |
| CI/CD platform                              | Azure DevOps                                                  |
| Network foundation                          | Completed                                               |
| Self-hosted agent and CI/CD hardening       | Assessment and validation completed; follow-up actions remain |
| Centralized monitoring and security logging | In progress                                                   |
| Next planned stage                          | Identity and privileged access                                |

### Implementation Roadmap

| Stage | Workstream                                 | Status                                 |
| ----- | ------------------------------------------ | -------------------------------------- |
| 01    | Network Foundation & Terraform CI/CD       | 🟢 Completed                           |
| 02    | Self-hosted Agent & CI/CD Hardening        | 🟢 Assessment and validation completed |
| 03    | Centralized Monitoring & Security Logging  | 🟠 In progress                         |
| 04    | Identity & Privileged Access               | ⚪ Planned                              |
| 05    | Azure Firewall & Centralized Egress        | ⚪ Planned                              |
| 06    | Governance & Policy Enforcement            | ⚪ Planned                              |
| 07    | Backup, Recovery & Resilience              | ⚪ Planned                              |
| 08    | Security Validation & Operational Handover | ⚪ Planned                              |

**Status definitions**

* **Completed:** The defined stage scope has been completed based on the documented implementation and acceptance evidence.
* **In progress:** Implementation or validation remains outstanding.
* **Planned:** Work has not yet started.

Stage 2 completion refers to the assessment and validation work performed. Remaining hardening and access-control improvements are tracked as follow-up activities.

The roadmap is updated as implementation and acceptance evidence become available.

---

## 🏗️ Architecture Overview

The POC uses a **hub-and-spoke network topology** to separate shared network infrastructure from workload subnet boundaries.

The hub provides shared networking locations, a subnet for the Terraform state private endpoint, and a subnet for the self-hosted Azure DevOps agent. The spoke separates web and application tiers into dedicated subnets.

<p align="center">
  <img src="docs/azure-landing-zone-topology.png" alt="Azure Landing Zone POC hub-and-spoke network topology" width="900">
</p>

<details>
<summary>View the SVG topology diagram</summary>

![Azure Landing Zone topology](docs/azure-landing-zone-topology.svg)

</details>

For a more detailed view of the implemented network architecture, see the [VNet topology diagram](docs/architecture/vnet-topology-poc.png).

### Network Address Plan

| Component                 | Resource name            | Address range  |
| ------------------------- | ------------------------ | -------------- |
| Hub VNet                  | `vnet-hub-poc-uaen-01`   | `10.0.0.0/22`  |
| Reserved firewall subnet  | `AzureFirewallSubnet`    | `10.0.0.0/26`  |
| Reserved Bastion subnet   | `AzureBastionSubnet`     | `10.0.0.64/26` |
| Shared hub subnet         | `snet-hub-shared`        | `10.0.1.0/24`  |
| Private endpoint subnet   | `snet-pe`                | `10.0.2.0/26`  |
| Azure DevOps agent subnet | `snet-agents`            | `10.0.2.64/26` |
| Spoke VNet                | `vnet-spoke-poc-uaen-01` | `10.1.0.0/22`  |
| Web subnet                | `snet-web`               | `10.1.0.0/24`  |
| Application subnet        | `snet-app`               | `10.1.1.0/24`  |

### Network Security

The web and application subnets have separate Network Security Groups (NSGs).

| NSG                   | Rule                                      | Behavior                                                      |
| --------------------- | ----------------------------------------- | ------------------------------------------------------------- |
| `nsg-web-poc-uaen-01` | `Deny-All-Inbound`, priority 4000         | Explicitly denies inbound traffic                             |
| `nsg-app-poc-uaen-01` | `Allow-Web-To-App-TCP-8080`, priority 100 | Allows TCP 8080 from the web subnet to the application subnet |
| `nsg-app-poc-uaen-01` | `Deny-All-Inbound`, priority 4000         | Explicitly denies other inbound traffic                       |

The application allow rule has a lower numerical priority than the explicit deny rule, so it is evaluated first.

Both hub-to-spoke and spoke-to-hub peering resources are configured. Forwarded traffic is allowed on both peerings, and gateway transit is enabled on the hub-to-spoke peering.

> **Architecture boundary:** The firewall and Bastion subnets are reserved locations, not evidence of deployed Azure Firewall or Azure Bastion resources. No virtual network gateway is included in the current network-foundation scope. VNet peering alone does not provide centralized firewall inspection or force traffic through a hub firewall.

---

## 🚀 Key Engineering Achievements

### 1. Reusable Terraform Networking

* Created a reusable VNet module for hub and spoke networks.
* Defined subnet address ranges and subnet-specific configuration through Terraform variables.
* Separated network resource creation from NSG definitions and peering configuration.
* Applied consistent resource naming and governance tags.

### 2. Controlled Infrastructure Delivery

* Established Terraform formatting and validation workflows.
* Integrated infrastructure changes with Azure DevOps CI/CD.
* Used a separate bootstrap configuration for the remote-state resources.
* Implemented a gated deployment workflow for the main branch.

### 3. Remote-State Security

* Configured Azure Storage for Terraform remote state.
* Disabled shared-key authorization and anonymous Blob access.
* Configured HTTPS-only transport and a minimum TLS version of 1.2.
* Enabled Blob versioning.
* Implemented private endpoint connectivity for the Terraform state Blob service.

### 4. Drift Detection and Reconciliation

Performed a controlled infrastructure drift exercise:

1. Added a tag manually to an application NSG in Azure.
2. Used Terraform planning to detect the difference.
3. Reviewed the proposed reconciliation.
4. Applied the reviewed saved plan.
5. Verified that the undeclared tag was removed.
6. Confirmed that a subsequent plan reported no changes.

This demonstrates a controlled configuration-reconciliation workflow for a resource-tag change.

### 5. Progressive Security Hardening

* Assessed the self-hosted Azure DevOps agent and associated CI/CD workflows.
* Reviewed security controls, permissions, and deployment approval behavior.
* Validated SSH authentication hardening in a disposable VM environment.
* Tracked remaining hardening activities separately from completed validation.

The disposable VM test does not, by itself, establish that the existing agent VM has been hardened.

---

## 🧱 Infrastructure as Code

Terraform is used to define and manage the network foundation and supporting infrastructure.

### Design Principles

| Principle              | Implementation                                                       |
| ---------------------- | -------------------------------------------------------------------- |
| Reusability            | Shared VNet module for hub and spoke                                 |
| Separation of concerns | Bootstrap, network, NSG, and supporting configurations are separated |
| Consistency            | Centralized naming and common resource tags                          |
| Repeatability          | Provider constraints and version-controlled lock files               |
| State management       | Azure Storage remote backend                                         |
| Change control         | Plan review and controlled application                               |
| Drift management       | Detect, review, reconcile, and verify                                |

### Repository Structure

The repository contains the main project README, architecture diagrams, supporting documentation, and reusable Terraform modules.

```text
azure-landing-zone-poc/
├── README.md
├── bootstrap/
├── docs/
│   ├── azure-landing-zone-topology.png
│   ├── azure-landing-zone-topology.svg
│   ├── stage-2-summary.md
│   ├── terraform-pipeline-workflow.png
│   ├── terraform-pipeline-workflow.svg
│   └── architecture/
│       ├── azure-landing-zone-poc-architecture.png
│       ├── monitoring-data-flow.svg
│       └── vnet-topology-poc.png
├── modules/
│   ├── vnet/
│   │   └── README.md
│   └── monitoring/
│       └── README.md
├── main.tf
├── locals.tf
├── nsg.tf
├── outputs.tf
├── providers.tf
├── variables.tf
└── versions.tf
```

This is a high-level illustration, not an exhaustive listing of every repository file. Review the actual directory structure for the current implementation.

### Terraform Module Documentation

* [VNet module documentation](modules/vnet/README.md)
* [Monitoring module documentation](modules/monitoring/README.md)
* [Stage 2 summary](docs/stage-2-summary.md)

---

## ⚙️ CI/CD Workflow

Azure DevOps is used to validate Terraform configuration and control infrastructure deployment.

The workflow separates validation from deployment and includes a gated application process for the main branch.

<p align="center">
  <img src="docs/terraform-pipeline-workflow.png" alt="Terraform CI/CD deployment workflow" width="900">
</p>

<details>
<summary>View the SVG workflow diagram</summary>

![Terraform pipeline workflow](docs/terraform-pipeline-workflow.svg)

</details>

### Workflow Overview

1. **Validation:** Run Terraform formatting and configuration validation checks.
2. **Initialization:** Initialize Terraform using the appropriate backend configuration for the workflow.
3. **Planning:** Generate and review the proposed infrastructure changes.
4. **Approval:** Apply the configured deployment approval controls.
5. **Application:** Apply the reviewed plan through the controlled pipeline.
6. **Verification:** Confirm the resulting infrastructure state and investigate unexpected differences.

The exact execution path depends on the pipeline stage and whether the operation targets the bootstrap or root configuration.

### Deployment Safety

Before applying infrastructure changes:

* Verify the intended Azure tenant and subscription.
* Confirm the backend configuration and required permissions.
* Review the complete Terraform plan.
* Confirm that the proposed changes affect only the intended resources.
* Treat saved plans and state files as sensitive artifacts.
* Use the configured deployment approval process.

The workflow diagram describes the intended deployment flow; it should not be interpreted as proof that every possible pipeline execution has been independently tested.

---

## 🔒 Remote State and Security Controls

The Terraform root configuration uses Azure Storage for remote state.

The documented design includes:

| Control                           | Purpose                                                                    |
| --------------------------------- | -------------------------------------------------------------------------- |
| Microsoft Entra ID authorization  | Supports identity-based authorization for Storage data-plane operations    |
| Shared-key authorization disabled | Reduces reliance on account-key authentication                             |
| Anonymous Blob access disabled    | Prevents anonymous access to Blob data                                     |
| Private container access          | Restricts anonymous container access                                       |
| HTTPS-only transport              | Requires encrypted transport                                               |
| TLS 1.2 minimum                   | Establishes a minimum transport security version                           |
| Blob versioning                   | Supports recovery from certain Blob changes                                |
| Private endpoint                  | Provides private network connectivity to the Blob service                  |
| Separate bootstrap configuration  | Allows state infrastructure to be managed separately from the root backend |

The bootstrap configuration is separated from the root network configuration to avoid a circular dependency during backend initialization.

**State security is critical:** Terraform state and saved plan files can contain sensitive infrastructure details. They should not be committed to source control or published as ordinary portfolio artifacts.

The presence of a control in Terraform configuration should not be treated as proof of its deployed state or operational effectiveness without corresponding validation.

---

## 📊 Monitoring and Security Logging

Stage 3 extends the foundation with centralized monitoring and security logging.

The workstream covers:

* Azure Monitor diagnostic settings.
* Log Analytics workspace integration.
* Resource log ingestion validation.
* Monitoring coverage and gap assessment.
* Alert configuration and notification testing.
* Documentation of monitoring controls and outstanding issues.

The monitoring work is **in progress**. The existence of a workspace or diagnostic setting does not, by itself, demonstrate complete monitoring coverage or successful alert delivery.

The monitoring architecture and data-flow diagram are available here:

![Monitoring data flow](docs/architecture/monitoring-data-flow.svg)

For implementation details, see the [monitoring module documentation](modules/monitoring/README.md).

---

## 🧪 Validation and Drift Reconciliation

The network-foundation implementation was checked using Terraform formatting and validation commands, and the final plan reported no changes at the time of validation.

A controlled drift-reconciliation exercise was also completed.

| Validation activity                               | Result                                          |
| ------------------------------------------------- | ----------------------------------------------- |
| Terraform formatting and configuration validation | Performed                                       |
| Network-foundation Terraform plan                 | Reported no changes at the time of validation   |
| Manual NSG tag change                             | Introduced as a controlled drift test           |
| Terraform drift detection                         | Detected the undeclared tag                     |
| Reviewed reconciliation plan                      | Proposed removal of the undeclared tag          |
| Reconciliation                                    | Applied                                         |
| Post-reconciliation verification                  | Tag absent; subsequent plan reported no changes |

These results demonstrate the documented network-foundation and drift-reconciliation exercises. They should not be interpreted as a claim that every resource, workload, security control, or future roadmap stage has been independently tested.

### Evidence and Validation Boundaries

Evidence should be linked to the relevant implementation and acceptance criteria.

Before publishing evidence, review it for:

* Credentials, access tokens, and private keys.
* Subscription and tenant identifiers that do not need to be public.
* Unnecessary principal identifiers or internal resource details.
* Local filesystem paths.
* Terraform state and saved plan contents.
* Information belonging to internal environments or third parties.

Only sanitized evidence intended for public release should be included in this repository.

---

## 🗺️ Next Engineering Milestones

The roadmap extends the current foundation through additional security and operational capabilities.

| Stage   | Planned engineering focus                                                                                    |
| ------- | ------------------------------------------------------------------------------------------------------------ |
| Stage 3 | Complete monitoring coverage assessment, log validation, and alert notification testing                      |
| Stage 4 | Review workload identity federation, service-connection permissions, role assignments, and privileged access |
| Stage 5 | Design and validate Azure Firewall, routing, and centralized egress                                          |
| Stage 6 | Implement and assess Azure Policy and governance controls                                                    |
| Stage 7 | Define backup scope, retention requirements, recovery testing, and resilience evidence                       |
| Stage 8 | Complete end-to-end validation, runbooks, outstanding-risk review, and operational handover                  |

Each stage should have defined acceptance criteria and supporting evidence before it is marked complete.

---

## 💰 Operational and Cost Considerations

The POC creates Azure networking resources and remote-state storage infrastructure. Charges may apply while these resources remain deployed.

Before leaving resources running:

* Review Azure Cost Management.
* Identify resources that are no longer required.
* Preserve infrastructure needed by subsequent stages.
* Review deletion plans before performing cleanup.

**Do not remove the Terraform backend while the root Terraform state still depends on it.**

Before destroying resources, capture required evidence, review the destroy plan, and confirm the resources selected for deletion.

---

## ⚠️ Known Limitations

The current POC has the following documented boundaries:

* Azure Firewall and Azure Bastion are not deployed; their subnets are reserved.
* No virtual network gateway is deployed.
* The original network-foundation implementation does not include application VMs or application endpoints.
* The TCP 8080 application NSG rule was not validated against a live endpoint as part of the original network-foundation implementation.
* The disposable SSH-hardening test does not, by itself, establish persistent hardening of the existing self-hosted agent.
* Centralized monitoring and security logging remain in progress.
* Identity and privileged-access improvements, centralized egress, governance, resilience, and operational handover remain future roadmap work.

These limitations are intentional scope boundaries for the current POC, not claims that the corresponding production capabilities have already been implemented.

---

## 🏁 Project Outcome

The completed Stage 1 network foundation demonstrates a repeatable Azure network architecture using Terraform, with subnet segmentation, explicit NSG policies, bidirectional VNet peering, secure remote-state configuration, consistent tagging, and a controlled drift-reconciliation workflow.

Stage 2 assessment and CI/CD approval validation have been completed, with remaining hardening actions tracked as follow-up work.

Stage 3 extends the platform with centralized monitoring and security logging, followed by identity, privileged access, centralized egress, governance, resilience, and operational acceptance.

The project demonstrates an evidence-driven approach to Azure infrastructure engineering and cloud security.

**This POC is a foundation for further evaluation, not a complete production landing zone.** Production adoption would require additional workload testing, identity and access review, routing and inspection design, monitoring coverage, policy enforcement, DNS strategy, resilience testing, and formal operational acceptance.
