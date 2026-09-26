# Lab 1

This project demonstrates a simple Infrastructure as Code workflow using **Packer, Terraform, and Ansible** on AWS.

## Architecture

```text
Packer
  │
  ▼
Custom Ubuntu AMI with Nginx
  │
  ▼
Terraform
  │
  ├── EC2 web-1
  ├── EC2 web-2
  └── EC2 web-3
        │
        ▼
      Ansible
        │
        ├── Set hostnames
        ├── Configure web pages
        └── Ensure Nginx is running
```

## Tools

* AWS
* Packer
* Terraform
* Ansible
* Ubuntu 24.04
* Nginx

AWS region: `eu-north-1`

## Project structure

```text
lab-1/
├── README.md
├── packer/
│   └── ubuntu-nginx.pkr.hcl
├── terraform/
│   └── main.tf
└── ansible/
    ├── ansible.cfg
    ├── playbook.yml
    ├── hosts
    └── roles/
        └── nginx/
            └── tasks/
                └── main.yml
```

## 1. Build the AMI

Initialize the Packer plugin:

```bash
packer init packer/ubuntu-nginx.pkr.hcl
```

Build the custom AMI:

```bash
packer build packer/ubuntu-nginx.pkr.hcl
```

The resulting AMI contains Ubuntu 24.04 with Nginx installed and enabled.

Copy the resulting AMI ID into `terraform/main.tf`.

## 2. Create the infrastructure

Initialize Terraform:

```bash
cd terraform
terraform init
```

Review the planned changes:

```bash
terraform plan
```

Create the three EC2 instances:

```bash
terraform apply
```

Terraform creates three `t3.micro` instances from the custom AMI.

The instances are named:

```text
web-1
web-2
web-3
```

After creation, note their public IP addresses.

## 3. Connect to the servers

SSH into a server using the AWS key pair:

```bash
ssh -i ~/.ssh/alroma-key.pem ubuntu@<server-public-ip>
```

The private key must have appropriate permissions:

```bash
chmod 400 ~/.ssh/alroma-key.pem
```

## 4. Configure the servers with Ansible

Update `ansible/hosts` with the public IP addresses of the newly created instances.

Test the SSH connection:

```bash
cd ../ansible
ansible all -m ping
```

Run the playbook:

```bash
ansible-playbook playbook.yml
```

Ansible configures each server by:

* Setting its hostname
* Creating a custom Nginx web page
* Ensuring Nginx is running and enabled

## 5. Test

SSH into any of the servers and run:

```bash
curl localhost
```

The server should return its custom web page, for example:

```text
Hello from web-1!
This server was configured by Ansible.
```

## 6. Clean up

When the infrastructure is no longer needed:

```bash
cd terraform
terraform destroy
```

This removes the EC2 instances managed by Terraform.

The custom AMI remains available and can be used to recreate the infrastructure later.

## Workflow summary

The complete workflow is:

```text
Packer → build AMI
Terraform → create EC2 instances
Ansible → configure EC2 instances
```

The infrastructure can be recreated from the code without manually configuring the servers.
