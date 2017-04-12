#Provides an network ACL in public subnet
resource "aws_network_acl" "wordpress_acl_public" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
  subnet_ids = ["${aws_subnet.public_wordpress1.id}", "${aws_subnet.public_wordpress2.id}"]  
 
  egress {
    protocol   = -1
    rule_no    = 100 
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name = "wordpress_acl_public"
  }
}

#Provides an network ACL in private subnet
resource "aws_network_acl" "wordpress_acl_db" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
  subnet_ids = ["${aws_subnet.DB_wordpress1.id}", "${aws_subnet.DB_wordpress2.id}"]  
 
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name = "wordpress_acl_db"
  }
}
