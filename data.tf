################################################################################
# Regional SSH public key lookups
################################################################################
data "aws_secretsmanager_secret_version" "customer_profile_ssh_public_key" {
  provider = aws.singapore

  secret_id = var.ssh_public_key_secret_id
}

data "aws_secretsmanager_secret_version" "account_ssh_public_key" {
  provider = aws.malaysia

  secret_id = var.ssh_public_key_secret_id
}

data "aws_secretsmanager_secret_version" "statement_ssh_public_key" {
  provider = aws.tokyo

  secret_id = var.ssh_public_key_secret_id
}

#################################################################################
# AWS Region references
################################################################################
data "aws_region" "singapore" {
  provider = aws.singapore
}

data "aws_region" "malaysia" {
  provider = aws.malaysia
}

data "aws_region" "tokyo" {
  provider = aws.tokyo
}