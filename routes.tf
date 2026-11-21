# Add each destination subnet to every private route table in the source VPC.

################################################################################
# Customer Profile private route tables to Account private subnets
################################################################################
resource "aws_route" "customer_to_account_subnet_1" {
  count    = length(module.customer_profile_vpc.private_route_table_ids)
  provider = aws.singapore

  route_table_id            = module.customer_profile_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.account_vpc_private_subnets[0]
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.customer_account.id

  depends_on = [
    aws_vpc_peering_connection_options.customer_account_requester,
    aws_vpc_peering_connection_options.customer_account_accepter,
  ]
}

resource "aws_route" "customer_to_account_subnet_2" {
  count    = length(module.customer_profile_vpc.private_route_table_ids)
  provider = aws.singapore

  route_table_id            = module.customer_profile_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.account_vpc_private_subnets[1]
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.customer_account.id

  depends_on = [
    aws_vpc_peering_connection_options.customer_account_requester,
    aws_vpc_peering_connection_options.customer_account_accepter,
  ]
}

################################################################################
# Account private route tables to Customer Profile private subnets
################################################################################
resource "aws_route" "account_to_customer_subnet_1" {
  count    = length(module.account_vpc.private_route_table_ids)
  provider = aws.malaysia

  route_table_id            = module.account_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.customer_profile_vpc_private_subnets[0]
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.customer_account.id

  depends_on = [
    aws_vpc_peering_connection_options.customer_account_requester,
    aws_vpc_peering_connection_options.customer_account_accepter,
  ]
}

resource "aws_route" "account_to_customer_subnet_2" {
  count    = length(module.account_vpc.private_route_table_ids)
  provider = aws.malaysia

  route_table_id            = module.account_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.customer_profile_vpc_private_subnets[1]
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.customer_account.id

  depends_on = [
    aws_vpc_peering_connection_options.customer_account_requester,
    aws_vpc_peering_connection_options.customer_account_accepter,
  ]
}

################################################################################
# Account private route tables to Statement private subnets
################################################################################
resource "aws_route" "account_to_statement_subnet_1" {
  count    = length(module.account_vpc.private_route_table_ids)
  provider = aws.malaysia

  route_table_id            = module.account_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.statement_vpc_private_subnets[0]
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.account_statement.id

  depends_on = [
    aws_vpc_peering_connection_options.account_statement_requester,
    aws_vpc_peering_connection_options.account_statement_accepter,
  ]
}

resource "aws_route" "account_to_statement_subnet_2" {
  count    = length(module.account_vpc.private_route_table_ids)
  provider = aws.malaysia

  route_table_id            = module.account_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.statement_vpc_private_subnets[1]
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.account_statement.id

  depends_on = [
    aws_vpc_peering_connection_options.account_statement_requester,
    aws_vpc_peering_connection_options.account_statement_accepter,
  ]
}

################################################################################
# Statement private route tables to Account private subnets
################################################################################
resource "aws_route" "statement_to_account_subnet_1" {
  count    = length(module.statement_vpc.private_route_table_ids)
  provider = aws.tokyo

  route_table_id            = module.statement_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.account_vpc_private_subnets[0]
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.account_statement.id

  depends_on = [
    aws_vpc_peering_connection_options.account_statement_requester,
    aws_vpc_peering_connection_options.account_statement_accepter,
  ]
}

resource "aws_route" "statement_to_account_subnet_2" {
  count    = length(module.statement_vpc.private_route_table_ids)
  provider = aws.tokyo

  route_table_id            = module.statement_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.account_vpc_private_subnets[1]
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.account_statement.id

  depends_on = [
    aws_vpc_peering_connection_options.account_statement_requester,
    aws_vpc_peering_connection_options.account_statement_accepter,
  ]
}
