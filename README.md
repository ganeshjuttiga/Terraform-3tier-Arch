# Terraform 3-Tier Architecture

This repository contains a fully working **3-tier architecture** setup using **Terraform** on **AWS Cloud**. It includes a VPC, public and private subnets, internet and NAT gateways, ELB, Auto Scaling Group, and Launch Templates.

## Architecture Overview

```
                         Internet
                            |
                      +-------------+
                      |   AWS ELB   |
                      +-------------+
                            |
                +-------------------------+
                |      Public Subnet      |
                +-------------------------+
                            |
                   +------------------+
                   | Auto Scaling Group |
                   |  (Launch Template) |
                   +------------------+
                            |
                +-------------------------+
                |     Private Subnet      |
                +-------------------------+
                            |
                      Backend Tier (e.g., DB)
```

## Files Included

### 1. `provider.tf`

Sets the AWS provider and region.

### 2. `vpc.tf`

Creates:

* VPC
* Public & Private Subnets
* Internet Gateway
* NAT Gateway
* Route Tables & Associations

### 3. `security_groups.tf`

Defines security groups allowing:

* All inbound & outbound traffic for testing
* Port-specific rules (optional)

### 4. `launch_template.tf`

Configures the EC2 Launch Template with:

* AMI ID
* Instance Type
* Key Pair
* AZ Placement

### 5. `elb.tf`

Creates a classic Load Balancer that distributes traffic to EC2 instances.

### 6. `autoscaling.tf`

Defines the Auto Scaling Group:

* Min/Max/Desired Capacity
* Health Check Type
* Load Balancer Integration

### 7. `outputs.tf`

Outputs relevant infrastructure information (optional).

### 8. `variables.tf`

Holds all variable declarations (if using variables).

---

## How to Use

1. **Clone the Repo**

```bash
git clone https://github.com/yourusername/terraform-3tier-arch.git
cd terraform-3tier-arch
```

2. **Initialize Terraform**

```bash
terraform init
```

3. **Preview the Plan**

```bash
terraform plan
```

4. **Apply the Infrastructure**

```bash
terraform apply --auto-approve
```

5. **Destroy (if needed)**

```bash
terraform destroy --auto-approve
```

---

## Prerequisites

* Terraform installed
* AWS CLI configured with appropriate credentials
* A valid Key Pair in AWS for EC2 SSH Access

---
