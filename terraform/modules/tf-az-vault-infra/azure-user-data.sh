#!/bin/bash

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

sudo apt-get update && sudo apt-get install vault

sudo apt-get install unzip

wget -O vault.zip https://releases.hashicorp.com/vault/1.6.0-rc+ent/vault_1.6.0-rc+ent_linux_amd64.zip

unzip vault.zip

rm vault.zip

sudo mv vault /usr/bin/vault

cat << EOF > /etc/vault.d/vault.hcl
ui = true

#mlock = true
#disable_mlock = true

storage "file" {
  path = "/opt/vault/data"
}

# HTTP listener
listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = 1
}

log_level = "Trace"

EOF

sudo service vault start

cat << 'EOF' > /home/azureuser/0-init-vault.sh

# Initialise Vault. Store keys locally FOR DEMO PURPOSES ONLY

export VAULT_ADDR=http://127.0.0.1:8200

vault operator init -key-shares=1 -key-threshold=1 > init-output.txt 2>&1

echo "Unseal: "$(grep Unseal init-output.txt | cut -d' ' -f4) >> vault.txt
echo "Token: "$(grep Token init-output.txt | cut -d' ' -f4) >> vault.txt
rm init-output.txt

# Unseal Vault
vault operator unseal $(cat vault.txt | grep Unseal | cut -f2 -d' ')

# Login to Vault
vault login $(cat vault.txt | grep Token | cut -f2 -d' ')
EOF

cat << 'EOF' > /home/azureuser/1-configure-azure-kmse.sh

export VAULT_ADDR=http://127.0.0.1:8200

export KEY_COLLECTION=${key_collection}
export PROVIDER="azurekeyvault"
export CLIENT_ID=${client_id}
export CLIENT_SECRET=${client_secret}
export TENANT_ID=${tenant_id}

echo "KEY_COLLECTION: $${KEY_COLLECTION}"
echo "PROVIDER: $${PROVIDER}"
echo "CLIENT_ID: $${CLIENT_ID}"
echo "CLIENT_SECRET: $${CLIENT_SECRET}"
echo "TENANT_ID: $${TENANT_ID}"

vault login $(cat vault.txt | grep Token | cut -f2 -d' ')

# Enable keymgmt secrets engine

vault secrets enable keymgmt

# Write keys

vault write keymgmt/key/rsa-1 type="rsa-2048"

vault write keymgmt/key/rsa-2 type="rsa-2048"

# Configure the KMS provider

vault write keymgmt/kms/keyvault \
  key_collection="$${KEY_COLLECTION}" \
  provider="$${PROVIDER}" \
  credentials=client_id="$${CLIENT_ID}" \
  credentials=client_secret="$${CLIENT_SECRET}" \
  credentials=tenant_id="$${TENANT_ID}"

# Write the keys to Azure Key Vault

vault write keymgmt/kms/keyvault/key/rsa-1 \
  purpose="encrypt,decrypt" \
  protection="hsm"

vault write keymgmt/kms/keyvault/key/rsa-2 \
  purpose="sign" \
  protection="hsm"

EOF

sudo chmod u+x /home/azureuser/{0,1}*.sh

sudo chown azureuser:azureuser /home/azureuser/{0,1}*.sh