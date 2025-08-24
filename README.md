# GPU AMI Packer Build

This project uses **HashiCorp Packer (HCL2)** to build **Amazon Machine Images (AMIs)** for GPU-enabled EC2 instances. 
The template is modular and supports multiple environments (`dev`, `beta`, `prod`).

---

## Features

* Modular configuration using `locals` for multi-environment support.
* Environment-specific AMI names, instance types, and subnet IDs.
* Fully compatible with AWS and Packer HCL2.
* NVIDIA Driver & CUDA installation from scratch
* System hardening & security scan report generation

---

## File Structure

```
scripts/              # Stage wise shell scripts to run 
├── main.pkr.hcl      # Main Packer template (builders + provisioners)
├── locals.pkr.hcl    # Environment-specific configuration
├── variables.pkr.hcl # User-defined Packer variables
├── versions.pkr.hcl  # Specifies required Packer plugins and their versions
├── README.md
```

---

## Prerequisites

* Packer >= 1.8
* AWS CLI configured with proper credentials
* Internet access from the build instance

---

## Variables

## Variables (`variables.pkr.hcl`)

| Variable              | Type   | Default                     | Description                                  |
| --------------------- | ------ | --------------------------- | -------------------------------------------- |
| `aws_region`          | string | `us-east-1`                 | AWS region for the AMI build                 |
| `instance_type`       | string | `g5.xlarge`                 | EC2 instance type for the build              |
| `ami_name`            | string | `gptoss-vllm-{{timestamp}}` | Name of the generated AMI (with timestamp)   |
| `associate_public_ip` | bool   | `true`                      | Whether the instance gets a public IP        |
| `vpc_id`              | string | `""`                        | VPC ID to launch the instance in (optional)  |
| `subnet_id`           | string | `""`                        | Subnet ID for the instance (optional)        |
| `root_volume_size`    | number | `100`                       | Size (GB) of the root volume                 |
| `env`                 | string | `dev`                       | Environment to build (`dev`, `beta`, `prod`) |

---

## Locals

Defined in `locals.pkr.hcl`:

* `env_config` – Maps each environment to its:
  * `ami_name` 
---

## Usage

### 1. Validate Packer template

```bash
packer validate .
```

### 2. Build AMI for a specific environment

```bash
# Dev environment
packer build -var "env=dev" .

# Beta environment
packer build -var "env=beta" .

# Prod environment
packer build -var "env=prod" .
```

> Note: Default environment is `dev` if not specified.

---

## Outputs

After a successful build, Packer outputs the AMI ID:

```
==> amazon-ebs.gpu: AMI: ami-0abcd1234efgh5678
```

You can use this AMI in EC2 launch templates, Terraform, or other AWS services.

---

## Notes

* Keep `locals.pkr.hcl` for environment-specific changes.
* Ensure proper network access from the build instance to download packages.

---

## Next Steps

* Integrate CI/CD pipelines to automatically build and deploy AMIs
* Use Terraform to provision infrastructure using the generated AMIs
* Add eBPF scripts for enhanced observability, security monitoring, and performance tracing