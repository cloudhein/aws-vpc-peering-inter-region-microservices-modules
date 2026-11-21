resource "aws_nat_gateway" "customer_profile_regional" {
  provider = aws.singapore

  vpc_id            = module.customer_profile_vpc.vpc_id
  availability_mode = "regional"

  tags = {
    Name = "${var.customer_profile_vpc_name}-regional-nat"
  }

  depends_on = [module.customer_profile_vpc]
}

resource "aws_route" "customer_profile_private_egress" {
  provider = aws.singapore
  count    = length(module.customer_profile_vpc.private_route_table_ids)

  route_table_id         = module.customer_profile_vpc.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.customer_profile_regional.id
}

resource "aws_nat_gateway" "account_regional" {
  provider = aws.malaysia

  vpc_id            = module.account_vpc.vpc_id
  availability_mode = "regional"

  tags = {
    Name = "${var.account_vpc_name}-regional-nat"
  }

  depends_on = [module.account_vpc]
}

resource "aws_route" "account_private_egress" {
  provider = aws.malaysia
  count    = length(module.account_vpc.private_route_table_ids)

  route_table_id         = module.account_vpc.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.account_regional.id
}