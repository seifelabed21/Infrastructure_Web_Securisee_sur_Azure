location                                = "francecentral"
project_name                            = "securecloud"
environment                             = "dev"
address_space                           = ["10.0.0.0/16"]
vm_admin_ssh_public_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTsPxt4aBt9bZHJ1+yyNk95GYUUDozTPd77Zs705kKLKKcbGXtl/VKro/gKQ7RN2WwePYtLZOSdbTIkyq8NHyteCMhKY5pvk02YlZ5oenJvVSqpOGBH1xkQ0+ukxmGN+E9g7HgTcMBrshQL3gf8XE5R7Xl9iQk6sVLwhqSdeIKgq6fNvFXrBLpxhyVj/PZbC3gGKcO1KZ/kGlKjRpwBU7vLB1k3D+K01vIoxS5NlF5UwG/3BcwqPWQQO2dD9yqKRJlRIMUa9Ald2u2hZHmNIA8oHAsbE2blqsPi0Vd7T5Sa8FUFGZkmwB9jTdp2jFZGTnZQP0DFZi02yK9IELEUvmf9kxIGr5F/e8L2hqIs5xkbLDbHn668aJEpLjHtSjyBcxrQiFcoWq8CzT1WgQ3AhwnQv3b+LdyzAZMkAPVHjRfxNYp/SLtDoNbyM7IluZmaS9eQnbZ58fszurax6+JHjNF6rNMQ+CRE8EwuLpoYaztoNc2aD4DkfwrMxGi8lUnGYJ6nyAEWKpdsefhF0m5kWjPesKlE+3Ll5D7uLJEZYuar96+F3NJKid8LSw1D6hrH2Ddv0SdIlP6UTwx27mCd9H1UtkqjRqZ/33Vf/qFo6kr/Tbu77QxVt6WZMTG9O+az3pyNwKC2x6JCi3cKiT6Too2wD5QdqVNaCp2f/YO8Qpatw== securecloud-vm-deploy-rsa"
github_repo_url                         = "https://github.com/seifelabed21/Infrastructure_Web_Securisee_sur_Azure"
runner_registration_token               = "A2QKPAT2MKU6YFOJLTGHXHDJZL6GW"
app_public_domain                       = "pfaseifaymen.me"
ssl_certificate_pfx_path                = "keys/pfaseifaymen.me.pfx"
ssl_certificate_pfx_password            = "weIzxRnZ5pvzv9x7NWBxc179rmfqTskRJlkCDsP64Ak"
enable_network_firewall                 = true
include_app_gateway_in_firewall_routing = false
firewall_subnet_cidr                    = "10.0.2.0/26"

tags = {
  environment = "dev"
  owner       = "student"
  project     = "pfa-network"
}