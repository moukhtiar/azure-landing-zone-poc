# PE-02 - SSH Hardening Validation

Date: 2026-10-26
Environment: Azure Landing Zone POC
Region: UAE North

## Resources
- VM: vm-ssh-hardening-poc-uaen-01
- NIC: nic-ssh-hardening-poc-uaen-01
- Private IP: 10.0.2.69
- VM size: Standard_FX2ms_v2
- Public IP: None
- Managed identity: None

## Validation Results
- Terraform apply: Succeeded
- Cloud-init status: done
- Cloud-init errors: None reported
- SSH hardening configuration file: Present
- SSH configuration syntax: Valid
- Root login: Disabled
- Public-key authentication: Enabled
- Password authentication: Disabled
- Keyboard-interactive authentication: Disabled

## Effective SSH Configuration

    permitrootlogin no
    pubkeyauthentication yes
    passwordauthentication no
    kbdinteractiveauthentication no

## Cleanup Verification
- Terraform destroy: Completed successfully
- Disposable VM: Confirmed absent from Azure
- Disposable NIC: Confirmed absent from Azure
- Local Terraform state: Removed after verifying it was empty
- Terraform backup state: Removed
- Saved Terraform plan: Removed
- Existing Azure DevOps agent: Not modified by this test
- Existing network configuration: Not modified by this test

## Scope and Limitations
This test validated the SSH authentication settings on a disposable VM.
It did not validate SSH service disablement or every possible network path.
It did not validate persistent hardening of the existing Azure DevOps agent.

## Result
PASS - The expected SSH authentication settings were applied and verified on the disposable VM.
