# Troubleshooting and Engineering Lessons

**Project:** Azure Landing Zone POC
**Document type:** Engineering case notes
**Status:** Living document — add dated test records as further acceptance checks are completed.

This report records what was observed, what the available evidence supports, and what remains uncertain. It intentionally avoids describing a suspected cause as proven unless the evidence establishes it.

## Case 1 — Private access to Terraform state

### Scenario
The Terraform state Storage Account was configured with public network access disabled. The self-hosted Azure DevOps agent needed to access the Blob endpoint through a Private Endpoint.

### Observations
- The Storage Account Networking view showed public network access set to Disabled.
- The Private Endpoint `pe-tfstate-blob-poc-uaen-01` was reported as Succeeded and Approved for the Blob subresource.
- On the agent VM, the Blob hostname resolved through `privatelink.blob.core.windows.net` to private IP `10.0.2.4`.
- An earlier TCP 443 test from the agent succeeded.
- Azure DevOps run `20261023.1` completed Validate, Plan, approval and Apply successfully after public access was disabled.
- From the laptop, the hostname continued to resolve to a public IP and TCP 443 was reachable. An unauthenticated request returned HTTP 403 `AuthorizationFailure`.

### What the evidence supports
The private DNS mapping and agent TCP test support private endpoint connectivity. The successful pipeline run supports that the Terraform workflow could access its backend under the tested conditions.

### What the evidence does not yet prove
The laptop's 403 response does not conclusively prove that Storage network rules denied the request; the response may reflect authorization. DNS resolution to a public IP or TCP 443 reachability alone does not prove that the data plane is accessible.

### Follow-up test
1. From the laptop, use an authenticated Storage request with an identity that would otherwise have the required data-plane permission.
2. Record the exact error and request correlation details without publishing tokens or sensitive headers.
3. From the self-hosted agent, confirm DNS resolves to `10.0.2.4` and perform an authenticated operation appropriate for the backend.
4. Compare results and retain redacted outputs.
5. If available, use Storage diagnostics to corroborate the caller, operation, status and request path.

## Case 2 — Pinning the hosted validation image

### Scenario
A pipeline run showed the hosted validation job using `ubuntu-latest`, accompanied by a platform migration warning.

### Change made
In the GitHub portfolio copy, `azure-pipelines.yml` was changed to pin the image to `ubuntu-24.04`. The change was committed as `53b53ec` (`Pin Terraform validation to Ubuntu 24.04`) and pushed to the GitHub portfolio repository.

### Boundary of the change
This change affects the GitHub portfolio repository only. It did not change the live Azure Repos pipeline. The portfolio YAML includes placeholder values and must not be copied into the live pipeline without deliberate review.

### Follow-up
If pinning the live pipeline is in scope, treat that as a separate change: update the live source, validate its diff, run the pipeline, and retain job details showing the selected image.

## Case 3 — Agent VM access hardening

### Scenario
The acceptance criteria required no public IP, denied inbound traffic, SSH key authentication only, root login disabled, and a non-root agent service account.

### Observations
- The agent VM had private IP `10.0.2.68` and no public IP.
- The effective rules showed `Deny-All-Inbound` at priority 4000.
- The live SSH configuration was checked with `sshd -t` and `sshd -T`.
- Effective settings were `permitrootlogin no`, `pubkeyauthentication yes`, `passwordauthentication no`, and `kbdinteractiveauthentication no`.
- SSH was inactive/disabled at the time of the check.
- The agent listener process was observed under a truncated name resembling `azdoage+`.

### Remaining gap
The SSH hardening was applied to the live VM, but persistence through Terraform or cloud-init has not been confirmed. The service account name/UID evidence is incomplete.

### Follow-up
1. Encode the approved SSH settings in the provisioning/bootstrap configuration.
2. Review the Terraform diff before applying.
3. Validate after provisioning with `sshd -t` and `sshd -T`.
4. Capture the agent systemd unit and process owner/UID; verify the service runs as a non-root user.
5. Do not enable SSH merely for evidence collection if it is not required.

## Case 4 — Preliminary repository secret scan

### Scenario
The project needed evidence that credentials and private key material were not committed.

### Observation
A PowerShell pattern scan of working files, excluding `.git` and `.terraform`, reported: `PASS: No configured secret patterns found.` The backend example contained placeholders. The WIF app registration was reported to have zero client secrets and zero certificates. The pipeline variable group included a public SSH key variable; a public key is not a private key.

### Limitation
A pattern scan can miss secrets and does not by itself cover all Git history, Terraform state/plan artifacts, cloud-init payloads, pipeline logs, or external variable stores.

### Follow-up
- Run a dedicated secret scanner against the current working tree and Git history.
- Verify there are no state, backup, tfvars, or private-key files in tracked or untracked project content.
- Review cloud-init and pipeline definitions for secret values or unsafe logging.
- Inspect variable names and metadata without copying secret values into the report.
- If a real secret is ever found in history, treat it as exposed and follow the appropriate rotation/removal process.

## Case 5 — Role assignment baseline

### Scenario
The acceptance criterion required documenting pipeline identity permissions and confirming they were unchanged.

### Observed current roles
- Contributor on `rg-network-poc-uaen-01`.
- Storage Blob Data Contributor on `sttfstatepocuaen7261`.

### Limitation
No before-change baseline was captured, so unchanged status is not proven.

### Follow-up
Export role assignments at relevant scopes and compare with a trusted baseline or Azure Activity Log. Record the role, principal, scope, assignment type and rationale. Review whether permissions can be narrowed without breaking Terraform operations.

## Engineering principles demonstrated

- Separate observations from conclusions.
- Validate network paths using DNS, transport, authentication, and service-level evidence rather than relying on a single test.
- Treat live VM configuration and repeatable infrastructure-as-code configuration as different things until persistence is tested.
- Keep portfolio configuration separate from production/working pipeline configuration.
- Use federated authentication to avoid long-lived service-principal secrets where supported.
- Keep evidence reproducible, dated, redacted, and linked to explicit acceptance criteria.
- Document open gaps honestly and close them with repeatable tests.

## Evidence record template

Use this template for each new test:

- **Date/time (UTC):**
- **Acceptance criterion:**
- **Environment / scope:**
- **Expected result:**
- **Command or procedure:**
- **Observed result:**
- **Conclusion supported by evidence:**
- **Limitations / alternative explanations:**
- **Evidence filename / ID:**
- **Follow-up action:**
