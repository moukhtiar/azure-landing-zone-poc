# Evidence Folder

Store only carefully reviewed and redacted evidence artifacts here.

Suggested naming convention:

- `EV-01-storage-networking-disabled.png`
- `EV-03-private-endpoint-approved.png`
- `EV-04-agent-private-dns.txt`
- `EV-05-agent-tcp443.txt`
- `EV-08-pipeline-run-summary.png`

## Public-repository safety

Do not add:
- Terraform state or saved plan files
- Private keys, PATs, access tokens, client secrets or authorization headers
- Unredacted pipeline logs or cloud-init output
- Screenshots exposing credentials or sensitive subscription/tenant details

The public report can describe evidence without publishing every raw artifact. Keep sensitive evidence in an appropriately restricted location.
