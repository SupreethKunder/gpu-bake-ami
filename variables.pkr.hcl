variable "aws_region" { 
    type = string
    default = "us-east-1"
}
variable "instance_type" { 
    type = string    
    default = "g5.xlarge" 
}
variable "ami_name" { 
    type = string
    default = "gptoss-vllm-{{timestamp}}" 
}
variable "associate_public_ip" { 
    type = bool
    default = true 
}
variable "vpc_id" { 
    type = string
    default = "" 
}
variable "subnet_id" { 
    type = string
    default = "" 
}
variable "root_volume_size" { 
    type = number
    default = 100 
}
variable "env" {
  type    = string
  default = "dev"
}
