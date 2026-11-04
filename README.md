# Secure Web Application Infrastructure

Terraform infrastructure for deploying a secure, segmented web application environment on Microsoft Azure. The project combines network isolation, managed security services, protected application delivery, and GitHub Actions automation into a repeatable infrastructure-as-code workflow.

## Project Overview

The platform is designed to host a web application behind layered network and application security controls:

- A dedicated Azure virtual network with separate subnets for the application, runner, Application Gateway, firewall, database, and VPN gateway.
- An Ubuntu application VM running the web workload.
- Azure Application Gateway with TLS termination and Web Application Firewall capabilities.
- Azure Firewall for controlled network traffic and protected subnet routing.
- Azure SQL configured with restricted network access.
- A point-to-site VPN gateway for administrative access.
- A dedicated GitHub Actions self-hosted runner VM for deployment automation.
- Optional trusted TLS certificate integration through Azure Key Vault.

The infrastructure is modular, parameterized, and intended to be deployed and destroyed consistently across development environments.

## Architecture


<img width="1376" height="768" alt="image" src="https://github.com/user-attachments/assets/e76e0cda-7d41-4c8f-8fbe-81bad114a78e" />

Azure Firewall can be enabled to route protected subnets through a central inspection point. Application Gateway routing through the firewall is configurable with `include_app_gateway_in_firewall_routing`.

## Technology Stack

- **Cloud:** Microsoft Azure
- **Infrastructure as Code:** Terraform
- **Terraform provider:** `azurerm`
- **Application host:** Ubuntu Linux VM
- **Web entry point:** Azure Application Gateway
- **Application security:** Web Application Firewall
- **Network security:** Azure Firewall, NSGs, subnet segmentation, and VPN access
- **Database:** Azure SQL
- **CI/CD:** GitHub Actions with a self-hosted runner
- **TLS:** Optional trusted PFX certificate with Azure Key Vault integration

## Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── deploy-vm-juice-shop.yml
├── docs/
│   └── Rapport_PFA.pdf
├── keys/                         # Local certificate and SSH artifacts
├── modules/
│   ├── app_service/
│   ├── application_gateway/
│   ├── firewall/
│   ├── github_runner/
│   ├── networking/
│   ├── nsg/
│   ├── resource_group/
│   ├── sql/
│   └── vpn_gateway/
├── scripts/
│   ├── prepare-namecheap-pfx.ps1
│   ├── set-github-vm-secrets.ps1
│   ├── terraform-lifecycle.ps1
│   └── terraform-lifecycle.sh
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
└── terraform.tfvars
```

## Prerequisites

- Terraform CLI 1.5 or later
- Azure CLI
- An Azure subscription with permission to create the required resources
- A logged-in Azure CLI session
- An OpenSSH public key for the application and runner VMs
- GitHub repository access if the self-hosted runner is enabled

Authenticate before deploying:

```powershell
az login
az account show --output table
```

## Configuration

Set environment-specific values in `terraform.tfvars` or provide a separate variables file. At minimum, configure the required VM SSH public key:

```hcl
project_name          = "pfa_infra"
location              = "francecentral"
vm_admin_ssh_public_key = "ssh-rsa AAAA..."
github_repo_url       = "https://github.com/seifelabed21/Secure_Web_App_Infrastructure"

tags = {
  environment = "dev"
  owner       = "student"
  project     = "pfa-network"
}
```

Important variables include:

- `project_name`, `location`, and `address_space` for the deployment identity and network.
- `vm_admin_ssh_public_key` for secure VM administration.
- `github_repo_url` and `runner_registration_token` for self-hosted runner registration.
- `enable_network_firewall` to enable or disable Azure Firewall.
- `include_app_gateway_in_firewall_routing` to control Application Gateway routing.
- `app_public_domain`, `ssl_certificate_pfx_path`, and `ssl_certificate_pfx_password` for trusted HTTPS.

Do not commit passwords, tokens, private keys, PFX files, or state files. The repository ignores local Terraform state, `.terraform`, and key material.

## Terraform Workflow

The lifecycle scripts initialize Terraform and provide consistent commands for validation, planning, deployment, output inspection, and destruction.

### Validate

```powershell
.\scripts\terraform-lifecycle.ps1 -Action validate
```

```bash
./scripts/terraform-lifecycle.sh validate
```

### Plan and Apply

```powershell
.\scripts\terraform-lifecycle.ps1 -Action plan
.\scripts\terraform-lifecycle.ps1 -Action apply
.\scripts\terraform-lifecycle.ps1 -Action apply -AutoApprove
```

```bash
./scripts/terraform-lifecycle.sh plan
./scripts/terraform-lifecycle.sh apply
AUTO_APPROVE=true ./scripts/terraform-lifecycle.sh apply
```

### Inspect Outputs

```powershell
.\scripts\terraform-lifecycle.ps1 -Action output
```

```bash
./scripts/terraform-lifecycle.sh output
```

### Destroy the Environment

```powershell
.\scripts\terraform-lifecycle.ps1 -Action destroy
.\scripts\terraform-lifecycle.ps1 -Action destroy -AutoApprove
```

```bash
./scripts/terraform-lifecycle.sh destroy
AUTO_APPROVE=true ./scripts/terraform-lifecycle.sh destroy
```

Destroy unused environments promptly to avoid unnecessary Azure charges.

## Trusted TLS and DNS

The Application Gateway can use a trusted certificate issued for the public application domain.

1. Generate a PFX from the issued certificate:

   ```powershell
   .\scripts\prepare-namecheap-pfx.ps1 `
     -DomainName pfaseifaymen.me `
     -IssuedCertificatePath C:\path\pfaseifaymen.me.crt `
     -PfxPassword "YourStrongPfxPassword" `
     -OutputPfxPath "keys\pfaseifaymen.me.pfx"
   ```

2. Set `app_public_domain`, `ssl_certificate_pfx_path`, and `ssl_certificate_pfx_password` in `terraform.tfvars`.
3. Apply the Terraform configuration.
4. Point the domain A record to the Application Gateway public IP, never directly to the backend VM.

The public IP can be retrieved with:

```powershell
terraform output application_gateway_public_ip
```

## GitHub Actions Deployment

The workflow in `.github/workflows/deploy-vm-juice-shop.yml` deploys the application to the VM through the self-hosted runner. After a destroy/redeploy cycle, the lifecycle scripts can refresh repository variables from Terraform outputs:

```powershell
.\scripts\terraform-lifecycle.ps1 `
  -Action apply `
  -AutoApprove `
  -SyncGithubVars
```

The repository can be overridden with `-GitHubRepo`. The Bash equivalent uses `SYNC_GITHUB_VARS=true` and `GITHUB_REPO`.

## Security Controls

- Segmented virtual network with dedicated subnets.
- Network Security Groups attached to protected subnets.
- Private administration through point-to-site VPN.
- Application Gateway as the controlled public entry point.
- WAF protection for inbound web traffic.
- Azure Firewall for optional centralized network inspection.
- Restricted database network access.
- Managed TLS certificate integration through Azure Key Vault.
- Secrets and private artifacts excluded from version control.

## Documentation

The project report is available in [`docs/Rapport_PFA.pdf`](docs/Rapport_PFA.pdf).

## Repository

[Secure_Web_App_Infrastructure](https://github.com/seifelabed21/Secure_Web_App_Infrastructure)
