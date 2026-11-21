################################################################################
# customer_profile_vpc
################################################################################
variable "customer_profile_vpc_name" {
  description = "Name to use for resources in the VPC"
  type        = string
  default     = ""
}

variable "customer_profile_vpc_cidr" {
  description = "IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "customer_profile_vpc_azs" {
  description = "Availability Zone names or IDs in the Region"
  type        = list(string)
  default     = []
}

variable "customer_profile_vpc_public_subnets" {
  description = "Public subnet CIDR blocks in the VPC"
  type        = list(string)
  default     = []
}

variable "customer_profile_vpc_private_subnets" {
  description = "Private subnet CIDR blocks in deployment order. Security group rules use the first subnet."
  type        = list(string)
  default     = []
}

variable "customer_profile_vpc_map_public_ip_on_launch" {
  description = "Whether instances launched in the subnet receive a public IP address"
  type        = bool
  default     = false
}

################################################################################
# account_vpc
################################################################################
variable "account_vpc_name" {
  description = "Name to use for resources in the VPC"
  type        = string
  default     = ""
}

variable "account_vpc_cidr" {
  description = "IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "account_vpc_azs" {
  description = "Availability Zone names or IDs in the Region"
  type        = list(string)
  default     = []
}

variable "account_vpc_public_subnets" {
  description = "Public subnet CIDR blocks in the VPC"
  type        = list(string)
  default     = []
}

variable "account_vpc_private_subnets" {
  description = "Private subnet CIDR blocks in deployment order. Security group rules use the first two subnets."
  type        = list(string)
  default     = []
}

variable "account_vpc_enable_nat_gateway" {
  description = "Whether the VPC module creates zonal NAT Gateways"
  type        = bool
  default     = false
}

################################################################################
# statement_vpc
################################################################################
variable "statement_vpc_name" {
  description = "Name to use for resources in the VPC"
  type        = string
  default     = ""
}

variable "statement_vpc_cidr" {
  description = "IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "statement_vpc_azs" {
  description = "Availability Zone names or IDs in the Region"
  type        = list(string)
  default     = []
}

variable "statement_vpc_public_subnets" {
  description = "Public subnet CIDR blocks in the VPC"
  type        = list(string)
  default     = []
}

variable "statement_vpc_private_subnets" {
  description = "Private subnet CIDR blocks in deployment order. Security group rules use the first two subnets."
  type        = list(string)
  default     = []
}

variable "statement_vpc_enable_nat_gateway" {
  description = "Whether the VPC module creates zonal NAT Gateways"
  type        = bool
  default     = false
}

################################################################################
# customer_profile_jump_security_group
################################################################################
variable "customer_profile_jump_security_group_name" {
  description = "Name of the Customer Profile jump host security group"
  type        = string
  default     = "JumpHost-SG"
}

locals {
  customer_profile_jump_security_group_ingress_rules = {
    ssh_from_admin = {
      description = "SSH from the administrator IPv4 address"
      cidr_ipv4   = var.customer_profile_admin_ipv4_cidr
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
    }
  }

  customer_profile_jump_security_group_egress_rules = {
    ssh_to_customer_app = {
      description                  = "SSH to Customer Profile app"
      referenced_security_group_id = module.customer_profile_security_group.id
      ip_protocol                  = "tcp"
      from_port                    = 22
      to_port                      = 22
    }
    ping_to_customer_app = {
      description                  = "Ping to Customer Profile app"
      referenced_security_group_id = module.customer_profile_security_group.id
      ip_protocol                  = "icmp"
      from_port                    = 8
      to_port                      = -1
    }
  }
}

################################################################################
# customer_profile_alb_security_group
################################################################################
variable "customer_profile_alb_security_group_name" {
  description = "Name of the public Customer Profile ALB security group"
  type        = string
  default     = "CustomerProfileALB-SG"
}

locals {
  customer_profile_alb_security_group_ingress_rules = {
    http_from_internet = {
      description = "Public HTTP to Customer Profile ALB"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
    }
    https_from_internet = {
      description = "Public HTTPS to Customer Profile ALB"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
    }
  }

  customer_profile_alb_security_group_egress_rules = {
    app_to_customer_targets = {
      description                  = "Application requests and health checks"
      referenced_security_group_id = module.customer_profile_security_group.id
      ip_protocol                  = "tcp"
      from_port                    = 9090
      to_port                      = 9090
    }
  }
}

################################################################################
# customer_profile_security_group
################################################################################
variable "customer_profile_security_group_name" {
  description = "Name of the private Customer Profile app security group"
  type        = string
  default     = "CustomerApp-SG"
}

locals {
  customer_profile_security_group_ingress_rules = {
    app_from_customer_alb = {
      description                  = "Application requests and health checks"
      referenced_security_group_id = module.customer_profile_alb_security_group.id
      ip_protocol                  = "tcp"
      from_port                    = 9090
      to_port                      = 9090
    }
    ssh_from_jump_host = {
      description                  = "SSH from the jump host"
      referenced_security_group_id = module.customer_profile_jump_security_group.id
      ip_protocol                  = "tcp"
      from_port                    = 22
      to_port                      = 22
    }
    ping_from_jump_host = {
      description                  = "Ping from the jump host"
      referenced_security_group_id = module.customer_profile_jump_security_group.id
      ip_protocol                  = "icmp"
      from_port                    = 8
      to_port                      = -1
    }
    ping_from_account_app = {
      description = "Ping from Account private subnet 1"
      cidr_ipv4   = var.account_vpc_private_subnets[0]
      ip_protocol = "icmp"
      from_port   = 8
      to_port     = -1
    }
  }

  customer_profile_security_group_egress_rules = merge(local.ec2_bootstrap_egress_rules, {
    http_to_account_alb_subnet_1 = {
      description = "HTTP to Account ALB subnet 1"
      cidr_ipv4   = var.account_vpc_private_subnets[0]
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
    }
    http_to_account_alb_subnet_2 = {
      description = "HTTP to Account ALB subnet 2"
      cidr_ipv4   = var.account_vpc_private_subnets[1]
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
    }
    https_to_account_alb_subnet_1 = {
      description = "HTTPS to Account ALB subnet 1"
      cidr_ipv4   = var.account_vpc_private_subnets[0]
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
    }
    https_to_account_alb_subnet_2 = {
      description = "HTTPS to Account ALB subnet 2"
      cidr_ipv4   = var.account_vpc_private_subnets[1]
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
    }
    ssh_to_account_app = {
      description = "SSH to Account private subnet 1"
      cidr_ipv4   = var.account_vpc_private_subnets[0]
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
    }
    ping_to_account_app = {
      description = "Ping to Account private subnet 1"
      cidr_ipv4   = var.account_vpc_private_subnets[0]
      ip_protocol = "icmp"
      from_port   = 8
      to_port     = -1
    }
  })
}

################################################################################
# account_alb_security_group
################################################################################
variable "account_alb_security_group_name" {
  description = "Name of the internal Account ALB security group"
  type        = string
  default     = "AccountALB-SG"
}

locals {
  account_alb_security_group_ingress_rules = {
    http_from_customer_app = {
      description = "HTTP from Customer Profile private subnet 1"
      cidr_ipv4   = var.customer_profile_vpc_private_subnets[0]
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
    }
    https_from_customer_app = {
      description = "HTTPS from Customer Profile private subnet 1"
      cidr_ipv4   = var.customer_profile_vpc_private_subnets[0]
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
    }
  }

  account_alb_security_group_egress_rules = {
    app_to_account_targets = {
      description                  = "Application requests and health checks"
      referenced_security_group_id = module.account_security_group.id
      ip_protocol                  = "tcp"
      from_port                    = 9090
      to_port                      = 9090
    }
  }
}

################################################################################
# account_security_group
################################################################################
variable "account_security_group_name" {
  description = "Name of the private Account app security group"
  type        = string
  default     = "AccountApp-SG"
}

locals {
  account_security_group_ingress_rules = {
    app_from_account_alb = {
      description                  = "Application requests and health checks"
      referenced_security_group_id = module.account_alb_security_group.id
      ip_protocol                  = "tcp"
      from_port                    = 9090
      to_port                      = 9090
    }
    ssh_from_customer_app = {
      description = "SSH from Customer Profile private subnet 1"
      cidr_ipv4   = var.customer_profile_vpc_private_subnets[0]
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
    }
    ping_from_customer_app = {
      description = "Ping from Customer Profile private subnet 1"
      cidr_ipv4   = var.customer_profile_vpc_private_subnets[0]
      ip_protocol = "icmp"
      from_port   = 8
      to_port     = -1
    }
    ssh_from_statement_app = {
      description = "SSH from Statement private subnet 1"
      cidr_ipv4   = var.statement_vpc_private_subnets[0]
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
    }
  }

  account_security_group_egress_rules = merge(local.ec2_bootstrap_egress_rules, {
    http_to_statement_alb_subnet_1 = {
      description = "HTTP to Statement ALB subnet 1"
      cidr_ipv4   = var.statement_vpc_private_subnets[0]
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
    }
    http_to_statement_alb_subnet_2 = {
      description = "HTTP to Statement ALB subnet 2"
      cidr_ipv4   = var.statement_vpc_private_subnets[1]
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
    }
    https_to_statement_alb_subnet_1 = {
      description = "HTTPS to Statement ALB subnet 1"
      cidr_ipv4   = var.statement_vpc_private_subnets[0]
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
    }
    https_to_statement_alb_subnet_2 = {
      description = "HTTPS to Statement ALB subnet 2"
      cidr_ipv4   = var.statement_vpc_private_subnets[1]
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
    }
    ssh_to_statement_app = {
      description = "SSH to Statement private subnet 1"
      cidr_ipv4   = var.statement_vpc_private_subnets[0]
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
    }
    ping_to_statement_app = {
      description = "Ping to Statement private subnet 1"
      cidr_ipv4   = var.statement_vpc_private_subnets[0]
      ip_protocol = "icmp"
      from_port   = 8
      to_port     = -1
    }
    ping_to_customer_app = {
      description = "Ping to Customer Profile private subnet 1"
      cidr_ipv4   = var.customer_profile_vpc_private_subnets[0]
      ip_protocol = "icmp"
      from_port   = 8
      to_port     = -1
    }
  })
}

################################################################################
# statement_alb_security_group
################################################################################
variable "statement_alb_security_group_name" {
  description = "Name of the internal Statement ALB security group"
  type        = string
  default     = "StatementALB-SG"
}

locals {
  statement_alb_security_group_ingress_rules = {
    http_from_account_app = {
      description = "HTTP from Account private subnet 1"
      cidr_ipv4   = var.account_vpc_private_subnets[0]
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
    }
    https_from_account_app = {
      description = "HTTPS from Account private subnet 1"
      cidr_ipv4   = var.account_vpc_private_subnets[0]
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
    }
  }

  statement_alb_security_group_egress_rules = {
    app_to_statement_targets = {
      description                  = "Application requests and health checks"
      referenced_security_group_id = module.statement_security_group.id
      ip_protocol                  = "tcp"
      from_port                    = 9090
      to_port                      = 9090
    }
  }
}

################################################################################
# statement_security_group
################################################################################
variable "statement_security_group_name" {
  description = "Name of the private Statement app security group"
  type        = string
  default     = "StatementApp-SG"
}

locals {
  statement_security_group_ingress_rules = {
    app_from_statement_alb = {
      description                  = "Application requests and health checks"
      referenced_security_group_id = module.statement_alb_security_group.id
      ip_protocol                  = "tcp"
      from_port                    = 9090
      to_port                      = 9090
    }
    ssh_from_account_app = {
      description = "SSH from Account private subnet 1"
      cidr_ipv4   = var.account_vpc_private_subnets[0]
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
    }
    ping_from_account_app = {
      description = "Ping from Account private subnet 1"
      cidr_ipv4   = var.account_vpc_private_subnets[0]
      ip_protocol = "icmp"
      from_port   = 8
      to_port     = -1
    }
  }

  statement_security_group_egress_rules = merge(local.ec2_bootstrap_egress_rules, {
    ping_to_account_app = {
      description = "Ping to Account private subnet 1"
      cidr_ipv4   = var.account_vpc_private_subnets[0]
      ip_protocol = "icmp"
      from_port   = 8
      to_port     = -1
    }
  })
}

################################################################################
# Jump host access
################################################################################
variable "customer_profile_admin_ipv4_cidr" {
  description = "Administrator public IPv4 address in /32 notation for jump host SSH"
  type        = string
  nullable    = false

  validation {
    condition     = can(cidrnetmask(var.customer_profile_admin_ipv4_cidr)) && endswith(var.customer_profile_admin_ipv4_cidr, "/32")
    error_message = "Set customer_profile_admin_ipv4_cidr to a single IPv4 address in /32 notation."
  }
}

#################################################################################
# ssh public keys ids for all across regions
################################################################################
variable "ssh_public_key_secret_id" {
  description = "Name of the Secrets Manager secret containing the OpenSSH public key in each Region"
  type        = string
  default     = "microservices/ssh-public-key"
}

################################################################################
# Application bootstrap settings
################################################################################
locals {
  ec2_bootstrap_egress_rules = {
    http_to_ubuntu_mirrors = {
      description = "HTTP for Ubuntu package mirrors"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
    }
    https_to_bootstrap_sources = {
      description = "HTTPS for GitHub releases and package mirrors"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
      from_port   = 443
      to_port     = 443
    }
  }

  app_archive_url = "https://github.com/nicholasjackson/fake-service/releases/download/v0.26.2/fake_service_linux_amd64.zip"
}

################################################################################
# customer_profile_ec2
################################################################################
variable "customer_profile_ec2_instance_type" {
  description = "x86_64 EC2 instance type for Customer Profile"
  type        = string
  default     = "t3.micro"
}

variable "customer_profile_ec2_ami" {
  description = "Optional Ubuntu x86_64 AMI ID for Customer Profile in Singapore"
  type        = string
  default     = null
}

variable "customer_profile_ec2_ami_ssm_parameter" {
  description = "SSM parameter for the Ubuntu 24.04 amd64 AMI in Singapore"
  type        = string
  default     = "/aws/service/canonical/ubuntu/server/noble/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

variable "customer_profile_ec2_key_pair_name" {
  description = "Name of the EC2 SSH key pair to register in Singapore"
  type        = string
  default     = "microservices-modules-ssh-key"
}

variable "customer_profile_ec2_root_block_device" {
  description = "Root EBS volume settings for Customer Profile"
  type = object({
    type                  = optional(string, "gp3")
    size                  = optional(number, 10)
    encrypted             = optional(bool, true)
    delete_on_termination = optional(bool, true)
  })
  default  = {}
  nullable = false
}

variable "customer_profile_upstream_url" {
  description = "URL of the Account service used by Customer Profile"
  type        = string
  default     = "http://account.nandaxsr.xyz"

  validation {
    condition     = can(regex("^https?://[a-zA-Z0-9.-]+(:80|:443)?/?$", var.customer_profile_upstream_url))
    error_message = "Use an HTTP or HTTPS origin with an optional port or trailing slash."
  }
}

locals {
  customer_profile_user_data = templatefile("${path.module}/templates/customer-profile.sh.tftpl", {
    upstream_url = var.customer_profile_upstream_url
    archive_url  = local.app_archive_url
  })
}

################################################################################
# customer_profile_jump_ec2
################################################################################
variable "customer_profile_jump_ec2_instance_type" {
  description = "x86_64 EC2 instance type for the jump host"
  type        = string
  default     = "t3.micro"
}

variable "customer_profile_jump_ec2_ami" {
  description = "Optional Ubuntu x86_64 AMI ID for the jump host in Singapore"
  type        = string
  default     = null
}

variable "customer_profile_jump_ec2_ami_ssm_parameter" {
  description = "SSM parameter for the Ubuntu 24.04 amd64 AMI in Singapore"
  type        = string
  default     = "/aws/service/canonical/ubuntu/server/noble/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# variable "customer_profile_jump_ec2_key_pair_name" {
#   description = "Existing EC2 SSH key pair name for the jump host in Singapore"
#   type        = string
#   default     = "microservices-ssh-key"
# }

variable "customer_profile_jump_ec2_root_block_device" {
  description = "Root EBS volume settings for the jump host"
  type = object({
    type                  = optional(string, "gp3")
    size                  = optional(number, 8)
    encrypted             = optional(bool, true)
    delete_on_termination = optional(bool, true)
  })
  default  = {}
  nullable = false
}

################################################################################
# account_ec2
################################################################################
variable "account_ec2_instance_type" {
  description = "x86_64 EC2 instance type for Account"
  type        = string
  default     = "t3.micro"
}

variable "account_ec2_ami" {
  description = "Optional Ubuntu x86_64 AMI ID for Account in Malaysia"
  type        = string
  default     = null
}

variable "account_ec2_ami_ssm_parameter" {
  description = "SSM parameter for the Ubuntu 24.04 amd64 AMI in Malaysia"
  type        = string
  default     = "/aws/service/canonical/ubuntu/server/noble/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

variable "account_ec2_key_pair_name" {
  description = "Name of the EC2 SSH key pair to register in Malaysia"
  type        = string
  default     = "microservices-modules-ssh-key"
}

variable "account_ec2_root_block_device" {
  description = "Root EBS volume settings for Account"
  type = object({
    type                  = optional(string, "gp3")
    size                  = optional(number, 10)
    encrypted             = optional(bool, true)
    delete_on_termination = optional(bool, true)
  })
  default  = {}
  nullable = false
}

variable "account_upstream_url" {
  description = "URL of the Statement service used by Account"
  type        = string
  default     = "http://statement.nandaxsr.xyz"

  validation {
    condition     = can(regex("^https?://[a-zA-Z0-9.-]+(:80|:443)?/?$", var.account_upstream_url))
    error_message = "Use an HTTP or HTTPS origin with an optional port or trailing slash."
  }
}

locals {
  account_user_data = templatefile("${path.module}/templates/account.sh.tftpl", {
    upstream_url = var.account_upstream_url
    archive_url  = local.app_archive_url
  })
}

################################################################################
# statement_ec2
################################################################################
variable "statement_ec2_instance_type" {
  description = "x86_64 EC2 instance type for Statement"
  type        = string
  default     = "t3.micro"
}

variable "statement_ec2_ami" {
  description = "Optional Ubuntu x86_64 AMI ID for Statement in Tokyo"
  type        = string
  default     = null
}

variable "statement_ec2_ami_ssm_parameter" {
  description = "SSM parameter for the Ubuntu 24.04 amd64 AMI in Tokyo"
  type        = string
  default     = "/aws/service/canonical/ubuntu/server/noble/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

variable "statement_ec2_key_pair_name" {
  description = "Name of the EC2 SSH key pair to register in Tokyo"
  type        = string
  default     = "microservices-modules-ssh-key"
}

variable "statement_ec2_root_block_device" {
  description = "Root EBS volume settings for Statement"
  type = object({
    type                  = optional(string, "gp3")
    size                  = optional(number, 10)
    encrypted             = optional(bool, true)
    delete_on_termination = optional(bool, true)
  })
  default  = {}
  nullable = false
}

locals {
  statement_user_data = templatefile("${path.module}/templates/statement.sh.tftpl", {
    archive_url = local.app_archive_url
  })
}

################################################################################
# ALB target health checks and TLS policy
################################################################################
locals {
  alb_health_check = {
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  alb_ssl_policy = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
}

################################################################################
# customer_profile_alb
################################################################################
variable "customer_profile_alb_certificate_arn" {
  description = "ARN of the existing ACM certificate for the Customer Profile ALB in Singapore"
  type        = string
  nullable    = false

  validation {
    condition     = startswith(var.customer_profile_alb_certificate_arn, "arn:aws:acm:ap-southeast-1:")
    error_message = "Use an ACM certificate ARN from ap-southeast-1."
  }
}

locals {
  customer_profile_alb_listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.customer_profile_alb_certificate_arn
      ssl_policy      = local.alb_ssl_policy

      forward = {
        target_group_key = "app"
      }
    }
  }

  customer_profile_alb_target_groups = {
    app = {
      name         = "microservices-customer-app"
      port         = 9090
      protocol     = "HTTP"
      target_type  = "instance"
      target_id    = module.customer_profile_ec2.id
      health_check = local.alb_health_check
    }
  }
}

################################################################################
# account_alb
################################################################################
variable "account_alb_certificate_arn" {
  description = "ARN of the existing ACM certificate for the Account ALB in Malaysia"
  type        = string
  nullable    = false

  validation {
    condition     = startswith(var.account_alb_certificate_arn, "arn:aws:acm:ap-southeast-5:")
    error_message = "Use an ACM certificate ARN from ap-southeast-5."
  }
}

locals {
  account_alb_listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "app"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.account_alb_certificate_arn
      ssl_policy      = local.alb_ssl_policy

      forward = {
        target_group_key = "app"
      }
    }
  }

  account_alb_target_groups = {
    app = {
      name         = "microservices-account-app"
      port         = 9090
      protocol     = "HTTP"
      target_type  = "instance"
      target_id    = module.account_ec2.id
      health_check = local.alb_health_check
    }
  }
}

################################################################################
# statement_alb
################################################################################
variable "statement_alb_certificate_arn" {
  description = "ARN of the existing ACM certificate for the Statement ALB in Tokyo"
  type        = string
  nullable    = false

  validation {
    condition     = startswith(var.statement_alb_certificate_arn, "arn:aws:acm:ap-northeast-1:")
    error_message = "Use an ACM certificate ARN from ap-northeast-1."
  }
}

locals {
  statement_alb_listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "app"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.statement_alb_certificate_arn
      ssl_policy      = local.alb_ssl_policy

      forward = {
        target_group_key = "app"
      }
    }
  }

  statement_alb_target_groups = {
    app = {
      name         = "microservices-statement-app"
      port         = 9090
      protocol     = "HTTP"
      target_type  = "instance"
      target_id    = module.statement_ec2.id
      health_check = local.alb_health_check
    }
  }
}