# Acceptance Criteria and Evidence Register

**Project:** Azure Landing Zone POC
**Status date:** 2026-10-23
**Purpose:** Public, concise summary of acceptance progress. The detailed working register is maintained separately in Excel.

> Status reflects the evidence currently described for this POC. “Met” is provisional until the original artifact is retained and reviewed. Do not treat this summary as independent security certification.

## Status definitions

- **Met (provisional):** Evidence described supports the criterion; retain/review original artifacts before sign-off.
- **Partially Met:** Evidence exists, but a specific proof gap remains.
- **Not Started:** No implementation or evidence has been recorded for the stretch objective.

## Core acceptance criteria

| ID | Acceptance criterion | Evidence reference | Status | Remaining work / closure condition |
|---|---|---|---|---|
| AC-01 | State storage public network access is disabled and laptop access is denied by network policy | EV-01 | **Partially Met** | Public access setting was confirmed Disabled, but laptop `curl` returned HTTP 403 `AuthorizationFailure`; capture an authenticated request and exact network-policy-specific failure. |
| AC-02 | State Storage Private Endpoint is provisioned and approved | EV-03 | **Met (provisional)** | Retain dated screenshot showing Succeeded, Approved, Blob subresource, account, VNet and subnet. |
| AC-03 | Agent resolves Blob FQDN to Private Endpoint IP and can connect on TCP 443 | EV-04, EV-05 | **Met (provisional)** | Preserve complete DNS and TCP output; private IP observed was `10.0.2.4`. |
| AC-04 | Validate uses a pinned hosted image | EV-09, EV-21 | **Partially Met** | GitHub portfolio YAML pins `ubuntu-24.04`; the live Azure Repos pipeline still showed `ubuntu-latest`. Keep these configurations distinct. |
| AC-05 | Plan and Apply succeed after state storage public access is disabled | EV-06, EV-07, EV-08 | **Met (provisional)** | Retain run summary and job details. Pipeline success supports backend availability but alone does not prove every operation traversed the Private Endpoint. |
| AC-06 | Agent VM has no public IP and inbound traffic is denied by effective NSG rules | EV-10, EV-11 | **Met (provisional)** | Retain VM Networking and effective security-rule screenshots; document the intended administration path. |
| AC-07 | SSH password and root login are disabled | EV-12 | **Partially Met** | Live effective configuration was hardened; make the settings persistent in Terraform/cloud-init and validate after provisioning. |
| AC-08 | Agent service runs as a dedicated non-root account | EV-12 (partial) | **Partially Met** | Capture full service username and UID; verify UID is not 0. |
| AC-09 | No PAT, private key, client secret, access key or token is exposed in repo, history, state, cloud-init or pipeline configuration | EV-13, EV-14, EV-15, EV-16 | **Partially Met** | Preliminary pattern scan passed, but perform a dedicated secret scan and check Git history, state/backup/tfvars/private-key files, cloud-init and pipeline logs/config. |
| AC-10 | Azure service connection uses Workload Identity Federation without a client secret/certificate | EV-16, EV-20 | **Met (provisional)** | Retain redacted service connection/app registration evidence. |
| AC-11 | Pipeline identity role assignments are documented and unchanged from baseline | EV-17 | **Partially Met** | Current roles were observed, but no before baseline exists. Compare exported assignments with a baseline or Azure Activity Log. |
| AC-12 | D2 carry-over tests are complete and indexed | EV-01–EV-22 | **Partially Met** | Consolidate original screenshots/logs in a dated evidence folder and close the gaps above. |

## Stretch objectives

| ID | Objective | Status | Suggested acceptance evidence |
|---|---|---|---|
| ST-01 | Replace VM agent with an injected Managed DevOps Pool and compare operations/cost | **Not Started** | Design, prerequisites, test pipeline, security comparison, cost estimate |
| ST-02 | Tighten broad TCP 443 egress; assess Azure Firewall FQDN rules and forced tunnelling | **Not Started** | Outbound dependency matrix, proposed rules/routes, Terraform plan and connectivity tests |
| ST-03 | Send Blob diagnostics to Log Analytics and query state operations | **Not Started** | Diagnostic settings, workspace destination and sample KQL results |
| ST-04 | Scheduled drift detection using `terraform plan -detailed-exitcode` | **Not Started** | Schedule, test run, exit-code handling and alert behavior |

## Evidence index

The evidence IDs refer to screenshots, logs and command outputs described during project work. The original artifacts are not embedded in this public report. Store them privately or publish only carefully redacted copies.

| Evidence ID | Artifact | Notes |
|---|---|---|
| EV-01 | Storage Networking settings and laptop access test | Exact network-policy denial still needs stronger proof |
| EV-03 | Private Endpoint overview | Reported Succeeded/Approved |
| EV-04 | Agent private DNS lookup | Private IP `10.0.2.4` |
| EV-05 | Agent TCP 443 test | Earlier clean test succeeded |
| EV-06 | Pipeline run summary | Plan/approval/Apply succeeded |
| EV-07 | Plan/Apply job details | Self-hosted pool and artifact handoff |
| EV-08 | Pipeline run after public access disabled | Run `20261023.1` |
| EV-09 | Validate hosted-agent details | Live pipeline showed `ubuntu-latest` |
| EV-10 | Agent VM Networking view | No public IP; private IP `10.0.2.68` |
| EV-11 | Agent NSG effective rules | Inbound deny; broad outbound HTTPS remains |
| EV-12 | SSH effective configuration/service state | Live hardening; persistence and full non-root proof remain open |
| EV-13 | Repository secret-pattern scan | Preliminary scan only |
| EV-14 | Backend HCL example | Uses placeholders |
| EV-15 | Variable group inventory | Includes public SSH key variable |
| EV-16 | Service connection/app registration credentials | WIF; zero client secrets/certificates reported |
| EV-17 | Role assignment inventory | Current roles; no baseline |
| EV-18 | Terraform agent VM configuration | Public key input and managed identity |
| EV-19 | Variable group public key variable | Public key, not private key |
| EV-20 | Service connection WIF screenshot | Redact sensitive details before public sharing |
| EV-21 | Git commit/repo status | Portfolio YAML pin only |
| EV-22 | Diagram commit | PNG diagrams published |

## Evidence safety

- Do not commit Terraform state, saved plan files, private keys, PATs, access tokens, or unredacted pipeline logs.
- Redact sensitive tenant/subscription details and internal identifiers before publishing screenshots.
- The GitHub portfolio repository is separate from the live Azure Repos project. The pipeline configuration in this repository is a portfolio example and does not update the live Azure Repos pipeline.
- Update statuses only after the evidence artifact is saved and the closure condition is satisfied.
