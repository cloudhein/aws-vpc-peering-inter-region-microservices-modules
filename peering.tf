################################################################################
# customer_profile_to_account
################################################################################
resource "aws_vpc_peering_connection" "customer_account" {
  provider = aws.singapore

  vpc_id      = module.customer_profile_vpc.vpc_id
  peer_vpc_id = module.account_vpc.vpc_id
  peer_region = data.aws_region.malaysia.region
  auto_accept = false

  tags = {
    Name = "microservices-customer-account"
  }

  depends_on = [
    module.customer_profile_security_group,
    module.account_alb_security_group,
    module.account_security_group,
  ]
}

resource "aws_vpc_peering_connection_accepter" "customer_account" {
  provider = aws.malaysia

  vpc_peering_connection_id = aws_vpc_peering_connection.customer_account.id
  auto_accept               = true

  tags = {
    Name = "microservices-customer-account"
  }
}

resource "aws_vpc_peering_connection_options" "customer_account_requester" {
  provider = aws.singapore

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.customer_account.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "customer_account_accepter" {
  provider = aws.malaysia

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.customer_account.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

################################################################################
# account_to_statement
################################################################################
resource "aws_vpc_peering_connection" "account_statement" {
  provider = aws.malaysia

  vpc_id      = module.account_vpc.vpc_id
  peer_vpc_id = module.statement_vpc.vpc_id
  peer_region = data.aws_region.tokyo.region
  auto_accept = false

  tags = {
    Name = "microservices-account-statement"
  }

  depends_on = [
    module.account_security_group,
    module.statement_alb_security_group,
    module.statement_security_group,
  ]
}

resource "aws_vpc_peering_connection_accepter" "account_statement" {
  provider = aws.tokyo

  vpc_peering_connection_id = aws_vpc_peering_connection.account_statement.id
  auto_accept               = true

  tags = {
    Name = "microservices-account-statement"
  }
}

resource "aws_vpc_peering_connection_options" "account_statement_requester" {
  provider = aws.malaysia

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.account_statement.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "account_statement_accepter" {
  provider = aws.tokyo

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.account_statement.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}
