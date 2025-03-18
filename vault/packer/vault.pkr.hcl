# Define a variable for AWS region, defaulting to the value of the AWS_REGION environment variable
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Define a variable for the Vault binary zip file path
variable "vault_zip" {
  type    = string
  default = "/Users/gueye/Downloads/vault_1.19.0_linux_amd64.zip"
}

# Define a variable for the VPC ID
variable "vpc_id" {
  type    = string
  default = "vpc-050836aa2c90a54ce"
}

# Define a variable for the Subnet ID
variable "subnet_id" {
  type    = string
  default = "subnet-0a9e59b23524a72a4"
}

# Fetch the most recent Amazon Linux 2 AMI using specific filters
data "amazon-ami" "amazon-linux-2" {
  filters = {
    name                = "amzn2-ami-hvm-2.*-x86_64-gp2" # Filter for Amazon Linux 2 AMIs
    root-device-type    = "ebs"                          # Use EBS-backed AMIs
    virtualization-type = "hvm"                         # Use hardware virtual machine (HVM) AMIs
  }
  most_recent = true                                     # Fetch the most recent AMI
  owners      = ["amazon"]                              # Owned by Amazon
  region      = var.aws_region                          # Use the specified AWS region
}

# Define an Amazon EBS source for building the AMI
source "amazon-ebs" "amazon-ebs-amazonlinux-2" {
  ami_description             = "Vault - Amazon Linux 2" # Description of the AMI
  ami_name                    = "vault-amazonlinux2-vault-course" # Name of the AMI
  ami_regions                 = ["us-east-1"]           # Regions where the AMI will be available
  ami_virtualization_type     = "hvm"                   # Virtualization type
  associate_public_ip_address = true                    # Assign a public IP address
  force_delete_snapshot       = true                    # Force delete snapshots
  force_deregister            = true                    # Force deregister the AMI
  instance_type               = "m5.large"              # Instance type for the build
  region                      = var.aws_region          # AWS region
  source_ami                  = data.amazon-ami.amazon-linux-2.id # Source AMI ID
  spot_price                  = "0"                     # Spot price (0 for on-demand)
  ssh_pty                     = true                    # Enable SSH PTY
  ssh_timeout                 = "5m"                    # SSH timeout
  ssh_username                = "ec2-user"              # SSH username
  tags = {                                               
    Name           = "HashiCorp Vault"                  # Tag for the AMI
    OS             = "Amazon Linux 2"                  # Operating system tag
  }
  subnet_id                   = var.subnet_id           # Subnet ID
  vpc_id                      = var.vpc_id              # VPC ID
}

# Define the build process
build {
  sources = ["source.amazon-ebs.amazon-ebs-amazonlinux-2"] # Use the defined Amazon EBS source

  # Upload the Vault binary zip file to the instance
  provisioner "file" {
    destination = "/tmp/vault.zip"                      # Destination path on the instance
    source      = var.vault_zip                         # Source file path
  }

  # Upload additional files to the instance
  provisioner "file" {
    destination = "/tmp"                                # Destination directory on the instance
    source      = "files/"                              # Source directory
  }
}
