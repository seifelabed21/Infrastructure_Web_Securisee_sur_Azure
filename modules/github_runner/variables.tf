variable "project_name" {
  type        = string
  description = "Project name used for resource naming"
}

variable "resource_group_name" {
  type        = string
  description = "Target resource group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "runner_subnet_id" {
  type        = string
  description = "Subnet ID where the self-hosted runner VM is deployed"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the runner VM"
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH public key for VM login"
}

variable "runner_vm_size" {
  type        = string
  description = "VM size for the GitHub self-hosted runner"
  default     = "Standard_B2as_v2"
}

variable "github_repo_url" {
  type        = string
  description = "Repository URL for runner registration, e.g. https://github.com/owner/repo"
  default     = "https://github.com/seifelabed21/Infrastructure_Web_Securisee_sur_Azure"
}

variable "runner_registration_token" {
  type        = string
  description = "Short-lived GitHub runner registration token. Leave empty to install runner without registering."
  default     = ""
  sensitive   = true
}

variable "runner_labels" {
  type        = list(string)
  description = "Additional labels assigned when registering the runner"
  default     = ["self-hosted", "linux", "x64", "vpn"]
}

variable "runner_version" {
  type        = string
  description = "GitHub Actions runner version"
  default     = "2.325.0"
}

variable "tags" {
  type        = map(string)
  description = "Tags for resources"
  default     = {}
}
