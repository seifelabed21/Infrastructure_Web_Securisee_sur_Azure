# Infrastructure Web Sécurisée sur Azure

Infrastructure cloud modulaire et reproductible pour le déploiement d'une application web sécurisée sur Microsoft Azure. Le projet est entièrement décrit avec Terraform et intègre la segmentation réseau, la protection des flux, l'accès d'administration privé et l'automatisation des déploiements.

> **Projet de fin d'études (PFA)** - Infrastructure as Code, sécurité cloud et CI/CD.

## 1. Objectif du projet

Ce projet a pour objectif de fournir une base Azure sécurisée pour héberger une application web tout en séparant clairement les responsabilités réseau et les accès d'administration.

Le déploiement comprend notamment :

- un Resource Group et un réseau virtuel Azure ;
- des sous-réseaux dédiés à l'application, à l'Application Gateway, au pare-feu, au runner CI/CD et à la passerelle VPN ;
- une machine virtuelle Ubuntu pour héberger l'application ;
- un Azure Application Gateway avec terminaison TLS et protection WAF ;
- un Azure Firewall pour l'inspection et le contrôle des flux réseau ;
- une base Azure SQL accessible uniquement depuis le réseau autorisé ;
- une passerelle VPN point-to-site pour l'administration privée ;
- une machine virtuelle GitHub Actions self-hosted runner ;
- l'intégration optionnelle d'un certificat TLS de confiance via Azure Key Vault.

## 2. Architecture

L'architecture complète du projet est illustrée ci-dessous :

<img width="1376" height="768" alt="Diagramme d'architecture de l'infrastructure Azure" src="https://github.com/user-attachments/assets/e76e0cda-7d41-4c8f-8fbe-81bad114a78e" />

Le trafic applicatif public est reçu par l'Application Gateway. Les sous-réseaux protégés peuvent être routés via Azure Firewall grâce à l'option `include_app_gateway_in_firewall_routing`. L'administration des ressources s'effectue à travers la passerelle VPN, sans exposer directement les services internes sur Internet.

## 3. Stack technique

| Domaine | Technologies |
|---|---|
| Cloud | Microsoft Azure |
| Infrastructure as Code | Terraform >= 1.5 |
| Provider | `hashicorp/azurerm` |
| Système d'exploitation | Ubuntu Linux |
| Entrée web | Azure Application Gateway |
| Protection applicative | Web Application Firewall (WAF) |
| Sécurité réseau | Azure Firewall, NSG, segmentation réseau |
| Base de données | Azure SQL |
| Accès administrateur | VPN point-to-site |
| CI/CD | GitHub Actions et self-hosted runner |
| Certificats | PFX et Azure Key Vault |

## 4. Structure du dépôt

```text
.
|-- .github/workflows/
|   `-- deploy-vm-juice-shop.yml
|-- docs/
|   `-- Rapport_PFA.pdf
|-- keys/                         # Fichiers locaux de certificats et de cles
|-- modules/
|   |-- app_service/
|   |-- application_gateway/
|   |-- firewall/
|   |-- github_runner/
|   |-- networking/
|   |-- nsg/
|   |-- resource_group/
|   |-- sql/
|   `-- vpn_gateway/
|-- scripts/
|   |-- prepare-namecheap-pfx.ps1
|   |-- set-github-vm-secrets.ps1
|   |-- terraform-lifecycle.ps1
|   `-- terraform-lifecycle.sh
|-- main.tf
|-- variables.tf
|-- outputs.tf
|-- provider.tf
|-- versions.tf
`-- terraform.tfvars
```

## 5. Modules Terraform

- **resource_group** : création du groupe de ressources et application des tags ;
- **networking** : réseau virtuel, sous-réseaux, associations et adresses réseau ;
- **nsg** : groupes de sécurité réseau appliqués aux sous-réseaux ;
- **firewall** : Azure Firewall, adresse publique et tables de routage ;
- **app_service** : machine virtuelle Ubuntu destinée à l'application web ;
- **application_gateway** : point d'entrée web, terminaison TLS et WAF ;
- **sql** : serveur et base Azure SQL avec accès réseau restreint ;
- **vpn_gateway** : passerelle VPN pour les connexions d'administration ;
- **github_runner** : machine virtuelle utilisée comme runner GitHub Actions.

## 6. Prérequis

- Terraform CLI 1.5 ou version ultérieure ;
- Azure CLI ;
- un abonnement Azure avec les droits de création des ressources ;
- une session Azure CLI authentifiée ;
- une clé publique SSH OpenSSH pour les machines virtuelles ;
- un accès au dépôt GitHub si le self-hosted runner est activé.

```powershell
az login
az account show --output table
```

## 7. Configuration

Les paramètres d'environnement sont définis dans `terraform.tfvars` ou dans un fichier de variables séparé. La clé SSH publique est obligatoire :

```hcl
project_name           = "pfa_infra"
location               = "francecentral"
vm_admin_ssh_public_key = "ssh-rsa AAAA..."

github_repo_url = "https://github.com/seifelabed21/Secure_Web_App_Infrastructure"

tags = {
  environment = "dev"
  owner       = "student"
  project     = "pfa-network"
}
```

Variables principales :

- `project_name`, `location` et `address_space` : identité et réseau du déploiement ;
- `vm_admin_ssh_public_key` : clé d'administration SSH ;
- `github_repo_url` et `runner_registration_token` : enregistrement du runner ;
- `enable_network_firewall` : activation du pare-feu Azure ;
- `include_app_gateway_in_firewall_routing` : routage de l'Application Gateway via le pare-feu ;
- `app_public_domain`, `ssl_certificate_pfx_path` et `ssl_certificate_pfx_password` : configuration HTTPS.

Les mots de passe, tokens, clés privées, fichiers PFX et fichiers d'état Terraform ne doivent jamais être versionnés.

## 8. Déploiement

Les scripts de cycle de vie uniformisent l'initialisation, la validation, le plan, l'application, l'affichage des sorties et la destruction de l'infrastructure.

### Validation

```powershell
.\scripts\terraform-lifecycle.ps1 -Action validate
```

```bash
./scripts/terraform-lifecycle.sh validate
```

### Planification et application

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

### Affichage des sorties

```powershell
.\scripts\terraform-lifecycle.ps1 -Action output
```

### Destruction

```powershell
.\scripts\terraform-lifecycle.ps1 -Action destroy
.\scripts\terraform-lifecycle.ps1 -Action destroy -AutoApprove
```

Il est recommandé de détruire les environnements inutilisés afin d'éviter les coûts Azure.

## 9. HTTPS et DNS

L'Application Gateway peut utiliser un certificat TLS de confiance fourni au format PFX :

1. Générer le PFX à partir du certificat délivré ;
2. renseigner `app_public_domain`, `ssl_certificate_pfx_path` et `ssl_certificate_pfx_password` ;
3. appliquer la configuration Terraform ;
4. faire pointer l'enregistrement DNS A vers l'adresse IP publique de l'Application Gateway.

Exemple de préparation du certificat :

```powershell
.\scripts\prepare-namecheap-pfx.ps1 `
  -DomainName pfaseifaymen.me `
  -IssuedCertificatePath C:\chemin\pfaseifaymen.me.crt `
  -PfxPassword "VotreMotDePasseFort" `
  -OutputPfxPath "keys\pfaseifaymen.me.pfx"
```

L'adresse IP publique peut être récupérée avec :

```powershell
terraform output application_gateway_public_ip
```

Le domaine doit pointer vers l'Application Gateway, et non directement vers la machine virtuelle.

## 10. Déploiement applicatif et CI/CD

Le workflow `.github/workflows/deploy-vm-juice-shop.yml` automatise le déploiement de l'application sur la machine virtuelle via le runner GitHub Actions auto-hébergé.

Après une destruction et un nouveau déploiement, les variables GitHub peuvent être resynchronisées depuis les sorties Terraform :

```powershell
.\scripts\terraform-lifecycle.ps1 `
  -Action apply `
  -AutoApprove `
  -SyncGithubVars
```

Le dépôt utilisé peut être précisé avec `-GitHubRepo`. L'équivalent Bash utilise `SYNC_GITHUB_VARS=true` et `GITHUB_REPO`.

## 11. Mesures de sécurité

- segmentation du réseau virtuel par sous-réseaux dédiés ;
- filtrage réseau avec des Network Security Groups ;
- administration privée via VPN point-to-site ;
- Application Gateway comme point d'entrée contrôlé ;
- protection WAF des requêtes web ;
- inspection centralisée optionnelle avec Azure Firewall ;
- accès restreint à la base Azure SQL ;
- chiffrement TLS avec certificat de confiance ;
- exclusion des secrets et artefacts privés du contrôle de version.

## 12. Sorties Terraform utiles

Les sorties suivantes sont disponibles après le déploiement :

- nom du Resource Group ;
- identifiant du réseau virtuel ;
- adresse IP publique de l'Application Gateway ;
- URL HTTPS de l'application ;
- adresses privées des machines virtuelles ;
- FQDN du serveur Azure SQL ;
- adresses IP publique et privée du pare-feu ;
- adresse IP publique de la passerelle VPN.

## 13. Rapport

Le rapport du projet est disponible dans [`docs/Rapport_PFA.pdf`](docs/Rapport_PFA.pdf).

## 14. Correspondance entre le rapport et l'implémentation

Cette section facilite la lecture du rapport en parallèle du code source. Elle associe les principaux chapitres du rapport aux fichiers et modules Terraform correspondants.

### Chapitre 2 — Architecture et structure Terraform

- [`main.tf`](main.tf) : orchestration des modules et définition de l'architecture globale ;
- [`modules/networking/`](modules/networking/) : réseau virtuel, sous-réseaux et routage de base ;
- [`modules/firewall/`](modules/firewall/) : Azure Firewall et tables de routage ;
- [`modules/application_gateway/`](modules/application_gateway/) : Application Gateway, terminaison TLS et WAF ;
- [`modules/vpn_gateway/`](modules/vpn_gateway/) : passerelle VPN point-to-site ;
- [`modules/app_service/`](modules/app_service/) : machine virtuelle Ubuntu hébergeant l'application ;
- [`modules/sql/`](modules/sql/) : serveur et base Azure SQL ;
- [`modules/nsg/`](modules/nsg/) : règles de sécurité réseau ;
- [`modules/resource_group/`](modules/resource_group/) : groupe de ressources Azure et tags communs.

### Chapitre 3 — Déploiement, CI/CD et TLS

- [`deploy-vm-juice-shop.yml`](.github/workflows/deploy-vm-juice-shop.yml) : workflow GitHub Actions exécuté par le runner auto-hébergé ;
- [`scripts/terraform-lifecycle.ps1`](scripts/terraform-lifecycle.ps1) et [`scripts/terraform-lifecycle.sh`](scripts/terraform-lifecycle.sh) : validation, planification, déploiement, destruction et synchronisation des variables GitHub ;
- [`scripts/prepare-namecheap-pfx.ps1`](scripts/prepare-namecheap-pfx.ps1) : préparation d'un certificat PFX de confiance pour l'Application Gateway ;
- [`variables.tf`](variables.tf) : paramètres du domaine public, du certificat PFX et de l'enregistrement du runner ;
- [`modules/github_runner/`](modules/github_runner/) : création et configuration de la machine virtuelle self-hosted runner.

### Chapitre 4 — Sécurité opérationnelle et contrôle des flux

- [`modules/firewall/main.tf`](modules/firewall/main.tf) : règles et routage Azure Firewall ;
- [`modules/nsg/main.tf`](modules/nsg/main.tf) : règles Network Security Group ;
- [`modules/networking/main.tf`](modules/networking/main.tf) : sous-réseaux, associations réseau et routage ;
- [`modules/application_gateway/main.tf`](modules/application_gateway/main.tf) : point d'entrée web et configuration WAF ;
- [`modules/vpn_gateway/main.tf`](modules/vpn_gateway/main.tf) : accès d'administration via VPN.

### Chapitre 5 — Tests et preuves

- [`docs/Rapport_PFA.pdf`](docs/Rapport_PFA.pdf) : rapport complet, résultats des tests et preuves de validation ;
- les fichiers de configuration Terraform et les sorties de déploiement permettent de reproduire les scénarios décrits dans le rapport.

## 15. Dépôt

[Secure_Web_App_Infrastructure](https://github.com/seifelabed21/Secure_Web_App_Infrastructure)
