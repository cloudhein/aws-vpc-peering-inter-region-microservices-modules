################################################################################
# Regional SSH key pairs
################################################################################
resource "aws_key_pair" "customer_profile" {
  provider = aws.singapore

  key_name   = var.customer_profile_ec2_key_pair_name
  public_key = trimspace(data.aws_secretsmanager_secret_version.customer_profile_ssh_public_key.secret_string)
}

resource "aws_key_pair" "account" {
  provider = aws.malaysia

  key_name   = var.account_ec2_key_pair_name
  public_key = trimspace(data.aws_secretsmanager_secret_version.account_ssh_public_key.secret_string)
}

resource "aws_key_pair" "statement" {
  provider = aws.tokyo

  key_name   = var.statement_ec2_key_pair_name
  public_key = trimspace(data.aws_secretsmanager_secret_version.statement_ssh_public_key.secret_string)
}