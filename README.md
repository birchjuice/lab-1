# Lab 1 — Infrastructure as Code

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
  ├── SSH key pair
  ├── Security group
  └── 3 EC2 instances
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

## 1. Configure AWS access

Log in to the TalTech AWS account using AWS SSO:

```bash
export AWS_PROFILE=taltech
aws sso login --profile taltech
```

Verify that the credentials work:

```bash
aws sts get-caller-identity
```

## 2. Build the AMI

Initialize the Packer plugins:

```bash
packer init packer/ubuntu-nginx.pkr.hcl
```

Build the AMI:

```bash
packer build packer/ubuntu-nginx.pkr.hcl
```

The resulting AMI contains Ubuntu 24.04 with Nginx installed and enabled.

## 3. Create the infrastructure

From the `terraform` directory:

```bash
terraform init
terraform plan
terraform apply
```

Terraform creates:

* An SSH key pair
* A security group allowing SSH and HTTP
* Three `t3.micro` EC2 instances from the custom AMI

The instances are named:

```text
web-1
web-2
web-3
```

Terraform also generates the private SSH key locally.

Set the correct permissions:

```bash
chmod 400 alroma-key.pem
```

## 4. Connect to the servers

SSH into a server using the AWS key pair.

From the `terraform` directory:

```bash
ssh -i alroma-key.pem ubuntu@<server-public-ip>
```

## 5. Configure the servers with Ansible

Update `ansible/hosts` with the public IPs of the newly created instances.

From the `ansible` directory:

```bash
ansible-playbook playbook.yml
```

Ansible:

* Sets the hostname
* Creates a custom Nginx web page
* Ensures Nginx is running and enabled

## 6. Test

SSH into any server and run:

```bash
curl localhost
```

Example output:

```text
Hello from web-1!
This server was configured by Ansible.
```

## 7. Clean up

When finished, destroy the infrastructure:

From the `terraform` directory:

```bash
terraform destroy
```

This removes the AWS key pair, security group, and EC2 instances.

The custom AMI remains and can be reused.

## Workflow summary

```text
Packer    → builds the machine image
Terraform → creates AWS infrastructure
Ansible   → provisions the machines
```

Infrastructure can be recreated from code without manually configuring AWS resources or servers.
