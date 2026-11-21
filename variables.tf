################################################################################
# customer_profile_vpc
################################################################################
variable "customer_profile_vpc_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "customer_profile_vpc_cidr" {
  description = "(Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`"
  type        = string
  default     = "10.0.0.0/16"
}

variable "customer_profile_vpc_azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "customer_profile_vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "customer_profile_vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "customer_profile_vpc_map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is `false`"
  type        = bool
  default     = false
}

################################################################################
# account_vpc
################################################################################
variable "account_vpc_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "account_vpc_cidr" {
  description = "(Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`"
  type        = string
  default     = "10.0.0.0/16"
}

variable "account_vpc_azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "account_vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "account_vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "account_vpc_enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

################################################################################
# statement vpc
################################################################################
variable "statement_vpc_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "statement_vpc_cidr" {
  description = "(Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`"
  type        = string
  default     = "10.0.0.0/16"
}

variable "statement_vpc_azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "statement_vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "statement_vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "statement_vpc_enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
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

  customer_profile_security_group_egress_rules = {
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
  }
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

  account_security_group_egress_rules = {
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
  }
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

  statement_security_group_egress_rules = {
    ping_to_account_app = {
      description = "Ping to Account private subnet 1"
      cidr_ipv4   = var.account_vpc_private_subnets[0]
      ip_protocol = "icmp"
      from_port   = 8
      to_port     = -1
    }
  }
}

################################################################################
# Customer Profile Jump host access
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
