# Azure Landing Zone Network Foundation

![Microsoft Azure](https://img.shields.io/badge/Microsoft_Azure-Network_Architecture-0078D4?logo=microsoftazure&logoColor=white)
![Terraform](https://img.shields.io/badge/Infrastructure_as_Code-Terraform-7B42BC?logo=terraform&logoColor=white)
![Engagement](https://img.shields.io/badge/Engagement-Technical_POC-198754)

A professional proof of concept (POC) demonstrating a reusable, Terraform-managed Azure hub-and-spoke network foundation. The implementation focuses on network segmentation, controlled connectivity, infrastructure-as-code practices, secure remote state, resource governance, and drift reconciliation.

> **POC scope:** This implementation establishes the network foundation and security policy boundaries. Azure Firewall and Azure Bastion subnets are reserved for potential future deployment; the corresponding services and associated workloads are not included in the current scope.

---

## Table of Contents

* [1. Project Overview](#1-project-overview)
* [2. Project Roadmap](#2-project-roadmap)
* [3. Architecture Overview](#3-architecture-overview)
* [4. Network Design](#4-network-design)
* [5. Infrastructure as Code](#5-infrastructure-as-code)
* [6. Secure Terraform Remote State](#6-secure-terraform-remote-state)
* [7. Azure DevOps CI/CD](#7-azure-devops-cicd)
* [8. Self-Hosted Agent Security](#8-self-hosted-agent-security)
* [9. Workload Identity Federation](#9-workload-identity-federation)
* [10. Security Controls](#10-security-controls)
* [11. Technical Reports and Evidence](#11-technical-reports-and-evidence)
* [12. Acceptance Criteria](#12-acceptance-criteria)
* [13. Deployment and Validation Workflow](#13-deployment-and-validation-workflow)
* [14. Operational Considerations](#14-operational-considerations)
* [15. Known Gaps and Future Improvements](#15-known-gaps-and-future-improvements)
* [16. Project Outcomes](#16-project-outcomes)

---

## 1. Project Overview

### Objective

Design and implement a secure, repeatable Azure network foundation using Terraform and Azure DevOps.

The project demonstrates how infrastructure engineers can build and validate Azure infrastructure through version-controlled configuration, automated pipelines, controlled network connectivity, and documented security controls.

The implementation serves as the first stage of a broader Azure Landing Zone engineering project.

### Key Objectives

* Establish a hub-and-spoke network architecture.
* Implement network segmentation using virtual networks, subnets, and network security groups.
* Deploy infrastructure using Terraform.
* Store Terraform state in Azure Storage with private connectivity.
* Run Terraform validation and deployment workflows through Azure DevOps.
* Authenticate pipeline workloads using Microsoft Entra ID workload identity federation.
* Operate a self-hosted Azure DevOps agent without a public IP address.
* Document security controls, troubleshooting activities, acceptance criteria, and remaining gaps.

### Technology Stack

| Technology                     | Purpose                                           |
| ------------------------------ | ------------------------------------------------- |
| Microsoft Azure                | Cloud infrastructure                              |
| Azure Virtual Network          | Network segmentation                              |
| Network Security Groups        | Network traffic filtering                         |
| Azure Storage                  | Terraform remote state                            |
| Azure Private Endpoint         | Private connectivity to Azure Storage             |
| Azure Private DNS              | Private endpoint name resolution                  |
| Terraform                      | Infrastructure as Code                            |
| Azure DevOps Repos             | Source control                                    |
| Azure DevOps Pipelines         | Infrastructure CI/CD                              |
| Azure DevOps self-hosted agent | Pipeline execution within the Azure network       |
| Microsoft Entra ID             | Workload identity and access management           |
| Azure CLI                      | Infrastructure administration and troubleshooting |
| PowerShell                     | Operational validation and troubleshooting        |

---

## 2. Project Roadmap

This repository begins with the network foundation. The broader project follows eight stages, progressively adding security, governance, monitoring, resilience, and operational readiness.

| Stage | Workstream                                 | Key Deliverables                                                                                   |
| ----- | ------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| 1     | Hub-and-spoke networking & Terraform CI/CD | VNets, subnets, NSGs, Terraform validation, saved plans, approval-controlled deployment            |
| 2     | Self-hosted agent & CI/CD hardening        | Restricted agent permissions, non-root execution, agent version review, pipeline artifact security |
| 3     | Centralized monitoring & security logging  | Log Analytics strategy, diagnostic settings, log ingestion validation, alert delivery              |
| 4     | Identity & privileged access               | Workload identity federation review, access scope validation, least-privilege role assignments     |
| 5     | Azure Firewall & centralized egress        | Hub egress architecture, routing design, controlled outbound connectivity, traffic-flow testing    |
| 6     | Governance & policy enforcement            | Azure Policy initiatives, assignments, resource governance, compliance evaluation                  |
| 7     | Backup, recovery & resilience              | Backup scope, retention requirements, recovery validation, evidence and remediation                |
| 8     | Security validation & operational handover | Connectivity and access tests, monitoring validation, runbooks, known risks, handover checklist    |

**Current focus:** Stage 1, with supporting implementation and security work relating to Stage 2 and Stage 4.

The roadmap is a target plan, not a claim that every stage has been implemented. Completion status should be updated as each stage is implemented and supported by evidence.

---

## 3. Architecture Overview

The implementation uses a hub-and-spoke design to separate shared infrastructure from workload networks.

* The **hub virtual network** contains shared infrastructure subnets, the self-hosted agent subnet, and the private endpoint subnet.
* The **spoke virtual network** contains application and web workload subnets.
* Azure Storage provides the Terraform remote state backend.
* A private endpoint provides private network connectivity to the Blob service.
* Private DNS provides name resolution for the storage private endpoint.
* Azure DevOps pipelines execute Terraform workflows using the self-hosted agent.

### Architecture Diagram

![Azure Landing Zone Network Foundation](docs/azure-landing-zone-topology.png)

*The diagram represents the network foundation. Reserved subnets should not be interpreted as proof that Azure Firewall or Azure Bastion has been deployed.*

**Additional format:** [View the SVG architecture diagram](docs/azure-landing-zone-topology.svg).

### Pipeline Workflow

![Terraform Pipeline Workflow](docs/terraform-pipeline-workflow.png)

**Additional format:** [View the SVG pipeline workflow](docs/terraform-pipeline-workflow.svg).

### Architectural Principles

1. **Separation of concerns:** Shared infrastructure and application workloads occupy separate virtual networks.
2. **Private service access:** Terraform state access uses a private endpoint and private DNS.
3. **Controlled administration:** The self-hosted agent has no public IP address.
4. **Infrastructure as Code:** Terraform configuration is version controlled and deployed through a defined workflow.
5. **Identity-based authentication:** Workload identity federation avoids storing a long-lived client secret or certificate for the configured service connection.
6. **Evidence-based security:** Controls are documented alongside validation results and outstanding gaps.

---

## 4. Network Design

The environment uses Azure region UAE North.

### 4.1 Hub Virtual Network

| Property        | Value                                                            |
| --------------- | ---------------------------------------------------------------- |
| Virtual network | `vnet-hub-poc-uaen-01`                                           |
| Address space   | `10.0.0.0/22`                                                    |
| Purpose         | Shared infrastructure, private endpoints, and pipeline execution |
| Region          | UAE North                                                        |

#### Hub Subnets

| Subnet                | Address Prefix | Intended Purpose                                   |
| --------------------- | -------------- | -------------------------------------------------- |
| `AzureFirewallSubnet` | `10.0.0.0/26`  | Reserved for a potential Azure Firewall deployment |
| `AzureBastionSubnet`  | `10.0.0.64/26` | Reserved for a potential Azure Bastion deployment  |
| `snet-hub-shared`     | `10.0.1.0/24`  | Shared infrastructure                              |
| `snet-pe`             | `10.0.2.0/26`  | Private endpoints                                  |
| `snet-agents`         | `10.0.2.64/26` | Self-hosted pipeline agent                         |

The reserved Firewall and Bastion subnets establish room for future expansion. They do not mean the respective services are currently deployed.

### 4.2 Spoke Virtual Network

| Property        | Value                                     |
| --------------- | ----------------------------------------- |
| Virtual network | `vnet-spoke-poc-uaen-01`                  |
| Address space   | `10.1.0.0/22`                             |
| Purpose         | Application and web workload segmentation |
| Region          | UAE North                                 |

#### Spoke Subnets

| Subnet     | Address Prefix | Intended Purpose      |
| ---------- | -------------- | --------------------- |
| `snet-web` | `10.1.0.0/24`  | Web workloads         |
| `snet-app` | `10.1.1.0/24`  | Application workloads |

### 4.3 Network Security

Network Security Groups are used to establish traffic filtering boundaries.

The self-hosted agent subnet has an inbound rule named `Deny-All-Inbound`, with priority `4000`, as recorded in the project validation.

An outbound HTTPS rule named `Allow-Outbound-HTTPS`, with priority `100`, permits TCP port 443 to the configured destination scope.

> **Security consideration:** An outbound HTTPS allow rule is not, by itself, a complete egress security strategy. Allowing TCP 443 to `Any` does not restrict the destination to trusted services. Destination restrictions, required service dependencies, DNS, routing, and the implications for agent connectivity should be assessed as part of the egress-hardening phase.

### 4.4 Network Validation

Validation should cover:

* Virtual network and subnet address allocation.
* Network security group associations.
* Required connectivity between the pipeline agent and Azure services.
* Private endpoint connectivity.
* Private DNS resolution.
* The absence of a public IP address on the self-hosted agent.
* Intended inbound and outbound traffic behavior.

A successful TCP connection proves connectivity to the tested endpoint and port; it does not independently prove that all security requirements are satisfied.

---

## 5. Infrastructure as Code

Terraform is used to define and manage the Azure infrastructure.

### Engineering Practices

* Maintain infrastructure configuration in version control.
* Use reusable variables rather than hardcoding environment-specific values throughout the configuration.
* Separate backend configuration from the primary infrastructure configuration.
* Validate Terraform configuration before planning changes.
* Review saved plans before applying infrastructure changes.
* Use pipeline controls for deployment approval where configured.
* Document operational assumptions and known limitations.
* Keep credentials, private keys, and other sensitive values out of source control.

### Typical Terraform Workflow

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Run these commands from the appropriate Terraform working directory and use the backend and variable configuration expected by the repository.

**Important:** A saved plan should be reviewed before application. Plan files can contain sensitive infrastructure values, so they should be handled and retained according to the project's security requirements.

### Example Backend Configuration

The repository includes an example backend configuration intended to illustrate the remote-state settings.

The example uses Azure AD authentication:

```hcl
use_azuread_auth = true
```

Use the actual backend settings supplied for the environment. Do not commit real credentials, tokens, private keys, or other secrets into backend configuration files.

---

## 6. Secure Terraform Remote State

Terraform state is stored in Azure Blob Storage.

| Property                        | Value                               |
| ------------------------------- | ----------------------------------- |
| Resource group                  | `rg-tfstate-poc-uaen-01`            |
| Storage account                 | `sttfstatepocuaen7261`              |
| Container                       | `tfstate`                           |
| State key                       | `landingzone.tfstate`               |
| Private endpoint                | `pe-tfstate-blob-poc-uaen-01`       |
| Private endpoint resource group | `rg-network-poc-uaen-01`            |
| Private DNS zone                | `privatelink.blob.core.windows.net` |
| Private endpoint service        | Blob                                |

### 6.1 Private Connectivity

The storage account's Blob service is accessed through a private endpoint in the hub network.

The private endpoint was reported as provisioned successfully and approved.

The private DNS zone is linked to the hub and spoke virtual networks. The pipeline agent's storage hostname resolution was observed returning the private endpoint IP address `10.0.2.4`.

This supports the intended design: the pipeline agent can resolve the storage endpoint to its private IP address when using the configured private DNS path.

### 6.2 Validation Performed

The project validation recorded the following:

* The private endpoint was provisioned and approved.
* The private DNS zone was linked to the relevant virtual networks.
* The pipeline agent resolved the Blob endpoint to the private IP address.
* The pipeline completed its Terraform Plan and Apply workflow after public network access was disabled on the storage account.

These results support the intended private-state design.

### 6.3 Important Validation Limitation

Testing from the laptop showed that the storage hostname could still resolve to a public IP address and that a TCP connection to port 443 could succeed. An unauthenticated HTTP request returned `403 AuthorizationFailure`.

These results do not establish that the laptop can access the storage data, nor do they independently prove network-level denial. A successful TCP connection only establishes that the endpoint accepted the connection.

A stronger test should use an authenticated request and record the exact response. The test should distinguish between an authorization failure and a network-rule denial.

### 6.4 State Security Requirements

* Restrict access to the state container.
* Use appropriate Azure RBAC permissions.
* Keep state access credentials out of source control.
* Validate private DNS and endpoint connectivity from the actual pipeline agent.
* Review storage-account public network access settings.
* Avoid sharing state files or saved plan files in public repositories.
* Assess state backup, recovery, retention, and access auditing requirements.

---

## 7. Azure DevOps CI/CD

Azure DevOps is used to manage source control and automate infrastructure validation and deployment.

### Pipeline Components

| Component                | Name                 |
| ------------------------ | -------------------- |
| Azure DevOps project     | `landing-zone-poc`   |
| Repository               | `landing-zone-poc`   |
| Pipeline                 | `landing-zone-poc`   |
| Self-hosted agent pool   | `pool-poc-vnet`      |
| Azure service connection | `sc-azure-poc-wif`   |
| Variable group           | `vg-landingzone-poc` |

### Pipeline Stages

The workflow includes:

1. **Validate** — Checks Terraform configuration and formatting.
2. **Plan** — Generates a Terraform execution plan.
3. **Approval** — Provides a control point before deployment where configured.
4. **Apply** — Applies the reviewed Terraform plan.

### Recorded Validation Result

Pipeline run `20261023.1` was reported to have completed the Validate, Plan, approval, and Apply stages successfully after public access was disabled on the Terraform state storage account.

This is evidence that the tested pipeline workflow could execute under the recorded conditions.

It does not establish that every future run, every pipeline branch, or every security control has been independently validated.

### Pipeline Workflow Diagram

The repository's pipeline diagram is available in both formats:

* [PNG workflow diagram](docs/terraform-pipeline-workflow.png)
* [SVG workflow diagram](docs/terraform-pipeline-workflow.svg)

### CI/CD Engineering Considerations

* Review pipeline permissions and repository permissions.
* Restrict who can modify production infrastructure pipelines.
* Protect deployment branches and environments.
* Keep sensitive values out of logs and published artifacts.
* Ensure approval requirements match the intended deployment risk.
* Review artifact retention and access permissions.
* Pin task and tool versions where practical.
* Verify the actual pipeline configuration rather than assuming that repository examples match the live pipeline.

### Image Version Consistency

The portfolio repository's pipeline YAML pins the validation image to `ubuntu-24.04`.

The live Azure DevOps pipeline was separately observed using `ubuntu-latest` in its Validate stage.

These are distinct configurations. The portfolio YAML change should not be interpreted as evidence that the live pipeline has also been changed.

---

## 8. Self-Hosted Agent Security

The self-hosted Azure DevOps agent executes Terraform operations from within the Azure environment.

### Agent Details

| Property           | Value                            |
| ------------------ | -------------------------------- |
| Virtual machine    | `vm-agent-poc-uaen-01`           |
| Operating system   | Ubuntu 24.04                     |
| Private IP address | `10.0.2.68`                      |
| Subnet             | `snet-agents`                    |
| Network interface  | `nic-agent-poc-uaen-01`          |
| Agent pool         | `pool-poc-vnet`                  |
| Public IP address  | None reported                    |
| Managed identity   | System-assigned identity enabled |
| VM size            | `Standard_FX2ms_v2`              |

### Security Controls Observed

* The agent VM has no public IP address.
* An inbound NSG rule named `Deny-All-Inbound` is configured.
* SSH configuration was inspected.
* Root SSH login was disabled in the inspected configuration.
* Public-key authentication was enabled.
* Password authentication was disabled.
* Keyboard-interactive authentication was disabled.
* The SSH configuration syntax check passed.
* SSH was observed as inactive or disabled at the time of inspection.

### SSH Hardening Status

The inspected SSH settings indicate the intended security configuration at the time of testing. However, persistence through infrastructure redeployment and cloud-init has not been fully confirmed.

Future validation should demonstrate that the SSH configuration is applied consistently and survives VM recreation.

### Agent Account Validation

The agent listener process was observed running under a truncated account name beginning with `azdoage+`.

The full account name, UID, group membership, and effective permissions still require evidence. Until verified, do not claim that the agent's non-root execution requirement has been conclusively demonstrated.

### Additional Hardening Opportunities

* Confirm the agent service runs under a dedicated non-root account.
* Restrict agent pool administration and pipeline authorization.
* Review installed packages and remove unnecessary software.
* Establish a patching and agent-version maintenance process.
* Persist security configuration through cloud-init or another configuration-management mechanism.
* Assess outbound destination restrictions.
* Review whether agent work directories and artifacts are cleaned up appropriately.
* Document the VM rebuild and recovery procedure.

---

## 9. Workload Identity Federation

The Azure DevOps service connection `sc-azure-poc-wif` uses workload identity federation to authenticate to Azure.

### Recorded Identity Findings

The configured application registration was reported to have:

* Zero client secrets.
* Zero certificates.
* One federated credential.

This supports the use of federated authentication without a long-lived client secret or certificate for this service connection.

### Identity and Authorization Review

The following role assignments were observed:

| Scope                    | Role                          | Review Consideration                                                          |
| ------------------------ | ----------------------------- | ----------------------------------------------------------------------------- |
| `rg-network-poc-uaen-01` | Contributor                   | Review whether this scope and role are necessary for every pipeline operation |
| `sttfstatepocuaen7261`   | Storage Blob Data Contributor | Confirm the role is scoped appropriately for state access                     |

These assignments were observed during the project, but a complete baseline and before-and-after comparison have not been established. Therefore, they should not be described as an unchanged or fully validated least-privilege configuration.

### Recommended Improvements

* Document all required permissions and their purposes.
* Prefer the narrowest scope that supports the required operation.
* Separate infrastructure deployment permissions from state-data access where practical.
* Review service connection authorization and pipeline permissions.
* Record the federated credential's issuer, subject, and audience.
* Verify that only the intended Azure DevOps workload can use the federated credential.
* Review role assignments periodically.

---

## 10. Security Controls

This section summarizes controls implemented or observed during the POC and identifies areas requiring further evidence.

| Control                              | Current Evidence                                                     | Remaining Consideration                                                        |
| ------------------------------------ | -------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| Hub-and-spoke segmentation           | Hub and spoke VNets and subnets defined                              | Validate required routes and permitted traffic flows                           |
| Agent has no public IP               | VM configuration inspected                                           | Retest after infrastructure changes                                            |
| Agent inbound filtering              | Inbound deny rule observed                                           | Validate effective rules and required connectivity                             |
| Private endpoint for Terraform state | Endpoint reported approved and provisioned                           | Maintain configuration and connectivity evidence                               |
| Private DNS                          | Agent resolved Blob hostname to private IP                           | Test from all relevant networks and clients                                    |
| Storage public access restriction    | Pipeline succeeded after public access was disabled                  | Validate using authenticated requests from allowed and disallowed networks     |
| Workload identity federation         | No client secrets or certificates; one federated credential observed | Review federated credential scope and role assignments                         |
| SSH hardening                        | Relevant settings inspected; syntax check passed                     | Confirm persistence and complete account evidence                              |
| Terraform validation and deployment  | Successful pipeline run recorded                                     | Retain run evidence and repeat tests after changes                             |
| Secret scanning                      | Preliminary pattern scan reported no matches                         | Expand scanning to history, state, generated files, and pipeline configuration |

Security validation should distinguish between a control being configured, a test being performed, and a test proving the intended security outcome.

---

## 11. Technical Reports and Evidence

Detailed reports are maintained separately to keep this README focused on the overall architecture and project status.

### Technical Reports

* [Architecture and Security Report](reports/architecture-and-security-report.md)
  Describes the architecture, network design, remote state, identity, CI/CD, security findings, and recommended improvements.

* [Acceptance Criteria Register](reports/acceptance-criteria-register.md)
  Tracks acceptance criteria, implementation status, validation evidence, and outstanding work.

* [Troubleshooting and Lessons Learned](reports/troubleshooting-and-lessons-learned.md)
  Documents technical issues, investigations, resolutions, and lessons learned during implementation.

* [Evidence Collection Guide](reports/evidence/README.md)
  Describes evidence organization and handling practices.

### Architecture and Workflow Diagrams

* [Azure Landing Zone Network Foundation — SVG](docs/azure-landing-zone-topology.svg)
* [Azure Landing Zone Network Foundation — PNG](docs/azure-landing-zone-topology.png)
* [Terraform Pipeline Workflow — SVG](docs/terraform-pipeline-workflow.svg)
* [Terraform Pipeline Workflow — PNG](docs/terraform-pipeline-workflow.png)

### Evidence Handling

Evidence should demonstrate the actual state of the environment at the time of validation.

Recommended evidence includes:

* Azure resource configuration and network settings.
* Private endpoint provisioning and connection status.
* Private DNS resolution results.
* Storage public network access settings.
* Azure DevOps pipeline run summaries.
* Terraform plan and apply results.
* Service connection authentication configuration.
* Role assignments and their scopes.
* Agent VM public IP and NSG configuration.
* SSH configuration and agent process identity.
* Authenticated connectivity tests and exact error messages.

Remove or redact tokens, secrets, private keys, credentials, sensitive identifiers, and other confidential data before committing evidence to a repository.

---

## 12. Acceptance Criteria

Acceptance criteria track the difference between implementation, validation, and remaining work.

The detailed status register is maintained in [Acceptance Criteria Register](reports/acceptance-criteria-register.md).

### Current Status Summary

The register currently records five core criteria as provisionally met:

* Private endpoint provisioning and approval.
* Private DNS and TCP connectivity to the private endpoint.
* Successful pipeline execution after storage public access was disabled.
* Agent VM without a public IP and with inbound deny configuration.
* Workload identity federation without a client secret or certificate.

Other criteria remain partially met, including:

* Laptop access denial evidence.
* Consistency between the live pipeline and portfolio YAML.
* Persistent SSH configuration.
* Full evidence of non-root agent execution.
* Comprehensive secret scanning.
* Role-assignment baseline and least-privilege validation.
* Consolidation of operational evidence.

The four stretch objectives—Managed DevOps Pool, egress hardening, Blob diagnostics, and scheduled drift detection—remain recorded as not started in the current register.

These statuses should be updated when new implementation evidence becomes available.

---

## 13. Deployment and Validation Workflow

Use the following workflow when making changes to the infrastructure.

### Step 1 — Review the Change

* Confirm the intended infrastructure change.
* Inspect the Terraform configuration and variable changes.
* Check that no credentials or other secrets have been introduced.
* Review any expected network or access impact.

### Step 2 — Validate Terraform

Run formatting and validation checks from the appropriate Terraform directory:

```bash
terraform fmt -check -recursive
terraform validate
```

Initialize the working directory first if required by the environment.

### Step 3 — Generate a Plan

```bash
terraform plan -out=tfplan
```

Review the proposed changes before proceeding.

### Step 4 — Apply Through the Approved Workflow

Use the configured Azure DevOps pipeline and approval controls.

Apply only the reviewed plan under the appropriate deployment permissions.

### Step 5 — Validate the Result

Check the relevant Azure resources and confirm that the actual state matches the intended configuration.

Depending on the change, this can include:

* Network and subnet configuration.
* NSG rules and associations.
* Private endpoint status.
* DNS resolution.
* Storage connectivity.
* Identity and role assignments.
* Pipeline results.

### Step 6 — Record Evidence

Update the relevant acceptance criteria and technical reports.

Record any unresolved issue as an open item rather than treating it as a successful test.

---

## 14. Operational Considerations

A production-ready landing zone requires more than successful infrastructure deployment.

The following operational areas should be addressed as the project progresses.

### Monitoring and Logging

* Define a centralized Log Analytics workspace strategy.
* Determine which Azure resources require diagnostic settings.
* Validate that logs are ingested and retained as intended.
* Define alerting requirements and notification paths.
* Establish procedures for investigating monitoring failures.

### Identity and Access

* Review role assignments at management group, subscription, resource group, and resource scopes as appropriate.
* Restrict service connection and pipeline permissions.
* Document the purpose of each privileged role assignment.
* Define periodic access reviews.

### Network Operations

* Document required traffic flows and their business purpose.
* Review DNS, routing, and egress dependencies.
* Test expected allowed and denied traffic.
* Plan for the future deployment of centralized egress controls where required.

### Resilience and Recovery

* Define Terraform state recovery requirements.
* Determine backup and retention requirements for in-scope resources.
* Test recovery procedures rather than relying on configuration alone.
* Document incident response and operational handover steps.

### Change Management

* Review Terraform plans before applying changes.
* Keep source-controlled configuration aligned with deployed infrastructure.
* Document exceptions and manual changes.
* Investigate unexpected drift and record remediation.

---

## 15. Known Gaps and Future Improvements

The POC establishes a foundation but does not yet demonstrate every capability expected of a complete enterprise landing zone.

| Area                   | Current Gap                                                 | Recommended Next Step                                                            |
| ---------------------- | ----------------------------------------------------------- | -------------------------------------------------------------------------------- |
| Centralized monitoring | Logging strategy and diagnostic coverage need completion    | Implement workspace, diagnostic settings, and alert validation                   |
| Identity               | Complete least-privilege baseline is not established        | Document required roles and compare assignments against the baseline             |
| Agent security         | Full non-root account evidence is outstanding               | Verify account identity and effective permissions                                |
| SSH persistence        | Persistence across redeployment is unconfirmed              | Apply and validate configuration through IaC or cloud-init                       |
| Egress                 | HTTPS rule allows a broad destination scope                 | Assess required destinations and implement appropriate restrictions              |
| Firewall               | Subnet reserved, service not in current scope               | Design and validate centralized egress in Stage 5                                |
| Bastion                | Subnet reserved, service not in current scope               | Assess secure administration requirements before deployment                      |
| Secret scanning        | Preliminary pattern scan only                               | Scan repository history and relevant generated configuration and state artifacts |
| Storage isolation      | Laptop network-denial proof is incomplete                   | Perform authenticated tests from allowed and disallowed networks                 |
| CI/CD consistency      | Portfolio YAML differs from the observed live image setting | Review and reconcile the two configurations intentionally                        |
| Drift management       | Scheduled drift detection not implemented                   | Define and test a scheduled plan and review workflow                             |
| Backup and recovery    | Full recovery validation is outstanding                     | Define recovery objectives and test the relevant recovery procedures             |
| Evidence               | Some controls lack complete before-and-after proof          | Capture evidence and update the acceptance register                              |

These gaps are tracked as future work, not as claims that the corresponding controls are already implemented.

---

## 16. Project Outcomes

The POC demonstrates practical engineering work across Azure networking, Terraform, CI/CD, identity, and security validation.

### Engineering Outcomes

* Established a hub-and-spoke network foundation.
* Defined network segmentation for shared infrastructure and application workloads.
* Configured a private endpoint for Terraform state access.
* Validated private DNS resolution from the self-hosted pipeline agent.
* Executed Terraform validation, planning, and application through Azure DevOps.
* Used workload identity federation for Azure authentication.
* Inspected agent VM network exposure and SSH security configuration.
* Documented security findings, operational limitations, and future improvements.

### Portfolio Value

This project provides a practical foundation for demonstrating:

* Azure network engineering.
* Terraform infrastructure management.
* Azure DevOps infrastructure CI/CD.
* Secure remote state design.
* Microsoft Entra ID workload identity federation.
* Self-hosted pipeline agent operations.
* Cloud security validation.
* Technical reporting and evidence-based engineering.

### Final Statement

The Azure Landing Zone Network Foundation is the first stage of a broader cloud engineering initiative. The roadmap extends beyond networking into identity, monitoring, governance, egress control, resilience, and operational handover.

The project will evolve through documented implementation stages, with acceptance criteria and evidence used to demonstrate progress and distinguish completed controls from planned improvements.
