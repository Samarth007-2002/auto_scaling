resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_new_vpc.id
    tags = {
        Name = "My IGW"
    }
}

# Public route table
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.my_new_vpc.id
    # all the traffic should be routed to the internet gateway
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }
    tags = {
        Name = "Public route table"
    }
    depends_on = [ aws_internet_gateway.my_igw ]
}

resource "aws_route_table_association" "public_subnet_1_association" {
    subnet_id      = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
    subnet_id      = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_3_association" {
    subnet_id      = aws_subnet.public_subnet_3.id
    route_table_id = aws_route_table.public_route_table.id
}

# Private route table
resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.my_new_vpc.id
    # all the traffic should be routed to the NAT gateway
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
    }
    tags = {
        Name = "Private route table"
    }
    depends_on = [ aws_nat_gateway.my_nat_gateway ]
}

resource "aws_route_table_association" "private_subnet_1_association" {
    subnet_id      = aws_subnet.private_subnet_1.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
    subnet_id      = aws_subnet.private_subnet_2.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_3_association" {
    subnet_id      = aws_subnet.private_subnet_3.id
    route_table_id = aws_route_table.private_route_table.id
}

# Allocate Elastic IP address for the NAT gateway
resource "aws_eip" "my_eip" {
    domain = "vpc"
    depends_on = [ aws_internet_gateway.my_igw ]
}

# NAT gateway: to provide Internet access to EC2 instances
resource "aws_nat_gateway" "my_nat_gateway" {
    allocation_id = aws_eip.my_eip.id
    subnet_id     = aws_subnet.public_subnet_1.id
    tags = {
        Name = "My NAT Gateway"
    }
    depends_on = [ aws_internet_gateway.my_igw ]
}
