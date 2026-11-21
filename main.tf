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

################################################################################
# customer_profile_ec2
################################################################################
module "customer_profile_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.4.1"

  providers = {
    aws = aws.singapore
  }

  name              = "microservices-customer-app"
  ami               = var.customer_profile_ec2_ami
  ami_ssm_parameter = var.customer_profile_ec2_ami_ssm_parameter
  instance_type     = var.customer_profile_ec2_instance_type
  key_name          = aws_key_pair.customer_profile.key_name

  subnet_id                   = module.customer_profile_vpc.private_subnets[0]
  associate_public_ip_address = false
  create_security_group       = false
  vpc_security_group_ids      = [module.customer_profile_security_group.id]

  user_data                   = local.customer_profile_user_data
  user_data_replace_on_change = true

  root_block_device = var.customer_profile_ec2_root_block_device

  depends_on = [
    module.customer_profile_vpc,
    module.customer_profile_security_group,
  ]
}

################################################################################
# customer_profile_jump_ec2
################################################################################
module "customer_profile_jump_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.4.1"

  providers = {
    aws = aws.singapore
  }

  name              = "microservices-jump"
  ami               = var.customer_profile_jump_ec2_ami
  ami_ssm_parameter = var.customer_profile_jump_ec2_ami_ssm_parameter
  instance_type     = var.customer_profile_jump_ec2_instance_type
  key_name          = aws_key_pair.customer_profile.key_name

  subnet_id                   = module.customer_profile_vpc.public_subnets[0]
  associate_public_ip_address = true
  create_security_group       = false
  vpc_security_group_ids      = [module.customer_profile_jump_security_group.id]

  root_block_device = var.customer_profile_jump_ec2_root_block_device

  depends_on = [
    module.customer_profile_vpc,
    module.customer_profile_jump_security_group,
  ]
}

################################################################################
# account_ec2
################################################################################
module "account_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.4.1"

  providers = {
    aws = aws.malaysia
  }

  name              = "microservices-account-app"
  ami               = var.account_ec2_ami
  ami_ssm_parameter = var.account_ec2_ami_ssm_parameter
  instance_type     = var.account_ec2_instance_type
  key_name          = aws_key_pair.account.key_name

  subnet_id                   = module.account_vpc.private_subnets[0]
  associate_public_ip_address = false
  create_security_group       = false
  vpc_security_group_ids      = [module.account_security_group.id]

  user_data                   = local.account_user_data
  user_data_replace_on_change = true

  root_block_device = var.account_ec2_root_block_device

  depends_on = [
    module.account_vpc,
    module.account_security_group,
  ]
}

################################################################################
# statement_ec2
################################################################################
module "statement_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.4.1"

  providers = {
    aws = aws.tokyo
  }

  name              = "microservices-statement-app"
  ami               = var.statement_ec2_ami
  ami_ssm_parameter = var.statement_ec2_ami_ssm_parameter
  instance_type     = var.statement_ec2_instance_type
  key_name          = aws_key_pair.statement.key_name

  subnet_id                   = module.statement_vpc.private_subnets[0]
  associate_public_ip_address = false
  create_security_group       = false
  vpc_security_group_ids      = [module.statement_security_group.id]

  user_data                   = local.statement_user_data
  user_data_replace_on_change = true

  root_block_device = var.statement_ec2_root_block_device

  depends_on = [
    module.statement_vpc,
    module.statement_security_group,
  ]
}

################################################################################
# customer_profile_alb
################################################################################
module "customer_profile_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.5.1"

  providers = {
    aws = aws.singapore
  }

  name                       = "microservices-customer"
  load_balancer_type         = "application"
  internal                   = false
  vpc_id                     = module.customer_profile_vpc.vpc_id
  subnets                    = module.customer_profile_vpc.public_subnets
  create_security_group      = false
  security_groups            = [module.customer_profile_alb_security_group.id]
  drop_invalid_header_fields = true
  enable_http2               = true
  enable_deletion_protection = false

  listeners     = local.customer_profile_alb_listeners
  target_groups = local.customer_profile_alb_target_groups
}

################################################################################
# account_alb
################################################################################
module "account_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.5.1"

  providers = {
    aws = aws.malaysia
  }

  name                       = "microservices-account"
  load_balancer_type         = "application"
  internal                   = true
  vpc_id                     = module.account_vpc.vpc_id
  subnets                    = module.account_vpc.private_subnets
  create_security_group      = false
  security_groups            = [module.account_alb_security_group.id]
  drop_invalid_header_fields = true
  enable_http2               = true
  enable_deletion_protection = false

  listeners     = local.account_alb_listeners
  target_groups = local.account_alb_target_groups
}

################################################################################
# statement_alb
################################################################################
module "statement_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.5.1"

  providers = {
    aws = aws.tokyo
  }

  name                       = "microservices-statement"
  load_balancer_type         = "application"
  internal                   = true
  vpc_id                     = module.statement_vpc.vpc_id
  subnets                    = module.statement_vpc.private_subnets
  create_security_group      = false
  security_groups            = [module.statement_alb_security_group.id]
  drop_invalid_header_fields = true
  enable_http2               = true
  enable_deletion_protection = false

  listeners     = local.statement_alb_listeners
  target_groups = local.statement_alb_target_groups
}