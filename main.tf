################################################################################
# customer_profile_vpc
################################################################################
module "customer_profile_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.8.0" # pin to exact version - HashiCorp Recommendation
  #   version = "~> 6.7.1" # >= 6.7.1, < 6.8.0 - accept patch releases within the same minior
  #   version = "~> 6.7" # >= 6.7.0, < 7.0.0 - accept minor and patch releases within the major version
  #   version = ">= 6.7.1" # Any later version, including new majors

  providers = {
    aws = aws.singapore
  }

  name = var.customer_profile_vpc_name
  cidr = var.customer_profile_vpc_cidr
  azs  = var.customer_profile_vpc_azs

  public_subnets  = var.customer_profile_vpc_public_subnets
  private_subnets = var.customer_profile_vpc_private_subnets

}

################################################################################
# account_vpc
################################################################################
module "account_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.8.0" # pin to exact version - HashiCorp Recommendation

  providers = {
    aws = aws.malaysia
  }

  name = var.account_vpc_name
  cidr = var.account_vpc_cidr
  azs  = var.account_vpc_azs

  public_subnets     = var.account_vpc_public_subnets
  private_subnets    = var.account_vpc_private_subnets
  enable_nat_gateway = var.account_vpc_enable_nat_gateway

}

################################################################################
# statement vpc 
################################################################################

module "statement_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.8.0" # pin to exact version - HashiCorp Recommendation

  providers = {
    aws = aws.tokyo
  }

  name = var.statement_vpc_name
  cidr = var.statement_vpc_cidr
  azs  = var.statement_vpc_azs

  public_subnets     = var.statement_vpc_public_subnets
  private_subnets    = var.statement_vpc_private_subnets
  enable_nat_gateway = var.statement_vpc_enable_nat_gateway

}

################################################################################
# customer_profile_jump_security_group
################################################################################
module "customer_profile_jump_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  providers = {
    aws = aws.singapore
  }

  name        = var.customer_profile_jump_security_group_name
  description = "Admin access to the Customer Profile jump host"
  vpc_id      = module.customer_profile_vpc.vpc_id

  ingress_rules = local.customer_profile_jump_security_group_ingress_rules

  egress_rules = local.customer_profile_jump_security_group_egress_rules

  tags = {
    Name = var.customer_profile_jump_security_group_name
  }
}

################################################################################
# customer_profile_alb_security_group
################################################################################
module "customer_profile_alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  providers = {
    aws = aws.singapore
  }

  name        = var.customer_profile_alb_security_group_name
  description = "Public Customer Profile ALB"
  vpc_id      = module.customer_profile_vpc.vpc_id

  ingress_rules = local.customer_profile_alb_security_group_ingress_rules

  egress_rules = local.customer_profile_alb_security_group_egress_rules

  tags = {
    Name = var.customer_profile_alb_security_group_name
  }
}

################################################################################
# customer_profile_security_group
################################################################################
module "customer_profile_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  providers = {
    aws = aws.singapore
  }

  name        = var.customer_profile_security_group_name
  description = "Private Customer Profile app"
  vpc_id      = module.customer_profile_vpc.vpc_id

  ingress_rules = local.customer_profile_security_group_ingress_rules

  egress_rules = local.customer_profile_security_group_egress_rules

  tags = {
    Name = var.customer_profile_security_group_name
  }
}

################################################################################
# account_alb_security_group
################################################################################
module "account_alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  providers = {
    aws = aws.malaysia
  }

  name        = var.account_alb_security_group_name
  description = "Internal Account ALB"
  vpc_id      = module.account_vpc.vpc_id

  ingress_rules = local.account_alb_security_group_ingress_rules

  egress_rules = local.account_alb_security_group_egress_rules

  tags = {
    Name = var.account_alb_security_group_name
  }
}

################################################################################
# account_security_group
################################################################################
module "account_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  providers = {
    aws = aws.malaysia
  }

  name        = var.account_security_group_name
  description = "Private Account app"
  vpc_id      = module.account_vpc.vpc_id

  ingress_rules = local.account_security_group_ingress_rules

  egress_rules = local.account_security_group_egress_rules

  tags = {
    Name = var.account_security_group_name
  }
}

################################################################################
# statement_alb_security_group
################################################################################
module "statement_alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  providers = {
    aws = aws.tokyo
  }

  name        = var.statement_alb_security_group_name
  description = "Internal Statement ALB"
  vpc_id      = module.statement_vpc.vpc_id

  ingress_rules = local.statement_alb_security_group_ingress_rules

  egress_rules = local.statement_alb_security_group_egress_rules

  tags = {
    Name = var.statement_alb_security_group_name
  }
}

################################################################################
# statement_security_group
################################################################################
module "statement_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  providers = {
    aws = aws.tokyo
  }

  name        = var.statement_security_group_name
  description = "Private Statement app"
  vpc_id      = module.statement_vpc.vpc_id

  ingress_rules = local.statement_security_group_ingress_rules

  egress_rules = local.statement_security_group_egress_rules

  tags = {
    Name = var.statement_security_group_name
  }
}
