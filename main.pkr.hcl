source "amazon-ebs" "gpu" {
  region        = var.aws_region
  instance_type     = var.instance_type
  ami_name          = local.env_config[var.env].ami_name

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"] # Canonical
    most_recent = true
  }

  ssh_username = "ubuntu"

  associate_public_ip_address = var.associate_public_ip
  vpc_id    = length(var.vpc_id)    > 0 ? var.vpc_id    : null
  subnet_id = length(var.subnet_id) > 0 ? var.subnet_id : null

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = var.ami_name
    Environment = "production"
    ManagedBy   = "packer"
  }
}

# Building GPU AMI
build {
  name    = "gpu-ami"
  sources = ["source.amazon-ebs.gpu"]

    # Part 1
    provisioner "shell" {
        pause_before = "10s"
        scripts = [
        "scripts/01-prerequisites.sh",
        "scripts/02-download-docker.sh",
        "scripts/03-download-nvidia.sh"
        ]
    }

    # Reboot the instance to reflect changes
    provisioner "shell" {
        expect_disconnect = true
        inline = ["sudo reboot"]
    }

    # Part 2
    provisioner "shell" {
        pause_before = "10s"
        scripts = [
        "scripts/04-verify-nvidia.sh",
        "scripts/05-system-hardening.sh",
        "scripts/06-security-reports.sh"
        ]
    }

    # Cleanup
    provisioner "shell" {
        scripts = ["scripts/07-cleanup.sh"]
    }

    # Download Trivy reports
    provisioner "file" {
        direction   = "download"
        source      = "/var/tmp/security-reports/trivy-ami.json"
        destination = "artifacts/trivy-ami.json"
    }
    provisioner "file" {
        direction   = "download"
        source      = "/var/tmp/security-reports/trivy-ami.sarif"
        destination = "artifacts/trivy-ami.sarif"
    }

    # Download Lynis report
    provisioner "file" {
        direction   = "download"
        source      = "/var/tmp/security-reports/lynis.log"
        destination = "artifacts/lynis.log"
    }

}

