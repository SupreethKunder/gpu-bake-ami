locals {
  env_config = {
    dev = {
      ami_name       = "gpu-ami-dev"
    }
    beta = {
      ami_name       = "gpu-ami-beta"
    }
    prod = {
      ami_name       = "gpu-ami-prod"
    }
  }
}
