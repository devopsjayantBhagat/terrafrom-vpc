resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public-1" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true" #it makes this a public subnet
    availability_zone = "us-east-1a"  
    tags = {
        Name = "public-1"
    }
}

resource "aws_subnet" "public-2" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = "true" #it makes this a public subnet
    availability_zone = "us-east-1b"
    tags = {
        Name = "public-2"
    }
}

resource "aws_subnet" "private-1" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = "true" #it makes this a priavte subnet
    availability_zone = "us-east-1a"
    tags = {
        Name = "private-1"
    }
}

resource "aws_subnet" "private-2" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.0.4.0/24"
    map_public_ip_on_launch = "true" #it makes this a priavte subnet
    availability_zone = "us-east-1b"
    tags = {
        Name = "private-2"
    }
}

# Createing route table
resource "aws_internet_gateway" "main-igw" {
    vpc_id = "${aws_vpc.main.id}"
    tags = {
        Name = "main-igw"
    }
}

resource "aws_route_table" "public-route1" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main-igw.id}"
  }
    tags = {
    Name = "public-route1"
  }
}

resource "aws_route_table_association" "public-1" {
  subnet_id = "${aws_subnet.public-1.id}"
  route_table_id = "${aws_route_table.public-route1.id}"
}

resource "aws_route_table_association" "public-2" {
  subnet_id = "${aws_subnet.public-2.id}"
  route_table_id = "${aws_route_table.public-route1.id}"
}

resource "aws_eip" "main-nat" {
   vpc = true
   tags = {
        Name = "main-nat"
    }
}


resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.main-nat.id}"
  subnet_id = "${aws_subnet.public-1.id}"
  
  tags = {
    Name = "nat-gw"
  }
}


resource "aws_route_table" "private-route1" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat-gw.id}"
  }
    tags = {
    Name = "private-route1"
  }
}

resource "aws_route_table_association" "private-1" {
  subnet_id = "${aws_subnet.private-1.id}"
  route_table_id = "${aws_route_table.private-route1.id}"
}

resource "aws_route_table_association" "private-2" {
  subnet_id = "${aws_subnet.private-2.id}"
  route_table_id = "${aws_route_table.private-route1.id}"
}
