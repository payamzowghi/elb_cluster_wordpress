#aws_vpc resource
resource "aws_vpc" "vpc_wordpress" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags {
    Name = "${var.name}"
  }
}

#The aws_internet_gateway resource 
resource "aws_internet_gateway" "ig_wordpress" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"

  tags {
    Name = "${var.name}-igw"
  }
}

#The aws_route_table_association_public1
resource "aws_route_table_association" "rt_association_public_wordpress1" {
  subnet_id      = "${aws_subnet.public_wordpress1.id}"
  route_table_id = "${aws_route_table.rt_public_wordpress.id}"
}

#The aws_route_table_association_public2
resource "aws_route_table_association" "rt_association_public_wordpress2" {
  subnet_id      = "${aws_subnet.public_wordpress2.id}"
  route_table_id = "${aws_route_table.rt_public_wordpress.id}"
}

#The aws_route_table_association_db1
resource "aws_route_table_association" "rt_association_db_wordpress1" {
  subnet_id      = "${aws_subnet.DB_wordpress1.id}"
  route_table_id = "${aws_route_table.rt_db_wordpress.id}"
}

#The aws_route_table_association_db2
resource "aws_route_table_association" "rt_association_db_wordpress2" {
  subnet_id      = "${aws_subnet.DB_wordpress2.id}"
  route_table_id = "${aws_route_table.rt_db_wordpress.id}"
}

#The aws_route_table_public
resource "aws_route_table" "rt_public_wordpress" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig_wordpress.id}"
  }

  tags {
    Name = "rt_public_wordpress"
  }
}

#The aws_route_table_db
resource "aws_route_table" "rt_db_wordpress" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"

  tags {
    Name = "rt_db_wordpress"
  }
}

#create and add public subnet in AZ_us_west_2a
resource "aws_subnet" "public_wordpress1" {
  vpc_id                  = "${aws_vpc.vpc_wordpress.id}"
  availability_zone       = "us-west-2a"
  cidr_block              = "172.16.2.0/24" 
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name}-public1"
  }
}

#create and add public subnet in AZ_us_west_2b
resource "aws_subnet" "public_wordpress2" {
  vpc_id                  = "${aws_vpc.vpc_wordpress.id}"
  availability_zone       = "us-west-2b"
  cidr_block              = "172.16.3.0/24"
  map_public_ip_on_launch = true  
  
  tags {
    Name = "${var.name}-public2"
  }
}

#create and add private subnet_db in AZ_us_west_2a
resource "aws_subnet" "DB_wordpress1" {
  vpc_id                  = "${aws_vpc.vpc_wordpress.id}"
  availability_zone       = "us-west-2a"
  cidr_block              = "172.16.4.0/24" 

  tags {
    Name = "${var.name-db}-db1"
  }
}

#create and add private subnet_db in AZ_us_west_2b
resource "aws_subnet" "DB_wordpress2" {
  vpc_id            = "${aws_vpc.vpc_wordpress.id}"
  availability_zone = "us-west-2b"
  cidr_block        = "172.16.5.0/24"

  tags {
    Name = "${var.name-db}-db2"
  }
}

