#!/bin/bash
##: This script configures the cloudshare startup VM

intall_deps() {
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    apt-get update
    apt-get install jq unzip -y
    wget https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip
    unzip terraform_1.0.0_linux_amd64.zip
    mv terraform /usr/local/bin
}

main() {
    intall_deps
}

main "$@"