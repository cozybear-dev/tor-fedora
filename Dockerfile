FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisites and add repositories for Google Cloud SDK and Terraform
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg2 curl apt-transport-https ca-certificates lsb-release grub-common && \
    # Add Google Cloud SDK key and repository for gcloud
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    # Add HashiCorp GPG key and repository for Terraform
    curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    # Update package lists
    apt-get update && \
    # Install Google Cloud SDK and Terraform
    apt-get install -y google-cloud-sdk terraform && \
    # Add aliases for Terraform commands
    echo "alias tf='terraform'" >> /etc/bash.bashrc && \
    echo "alias pl='terraform plan -refresh=false'" >> /etc/bash.bashrc && \
    echo "alias fpl='terraform plan'" >> /etc/bash.bashrc && \
    echo "alias ap='terraform apply'" >> /etc/bash.bashrc && \
    echo "alias apf='terraform apply -refresh=false'" >> /etc/bash.bashrc && \
    echo "alias in='terraform init'" >> /etc/bash.bashrc && \
    echo "alias de='terraform destroy'" >> /etc/bash.bashrc && \
    # Clean up
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]