# Vault Azure Key Management Secrets Engine Demo
A demo implementation of Vault's Key Management Secrets Engine, integrating with Azure Key Vault. Utilises features introduced in Vault 1.6.0


## Pre-Requisites
* An Azure account
* Terraform (tested with v0.13.2)

It may be possible to implement the demo with other versions of the above software, but this is neither tested
or guaranteed.

## Steps

1. cd to terraform/control
1. Optionally replace the values in `terraform.tfvars` to suit your own use case (e.g. creator name, network address prefixes, etc)
1. Run `terraform init`
1. Optionally run `terraform plan` to review the resources that will be created.
1. Run `terraform apply` to apply the changes.
1. Once the Terraform run is complete, you will find a file called `vault-ssh.pem` in the control directory. Use this, combined with the outputted public_ip_address to ssh onto the Vault VM.
1. Run the numbered scripts in the `/home/azureuser` directory in numerical order to first initialise and unseal Vault, and then configure the Key Management Secrets Engine.


## Warning
This demo is provided as-is with no support or guarantee. It makes no claim as to "production-readiness" in areas including but not limited to:
- Configuration of Vault (including unsealing and configure Vault)
- Configuration of Azure
