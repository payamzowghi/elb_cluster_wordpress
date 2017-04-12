#security group_for EC2 instance(incoming or outgoing traffic HTTP and ssh) 
resource "aws_security_group" "wordpress_instance" {
  vpc_id      = "${aws_vpc.vpc_wordpress.id}"
  description = "security-group-instance"  

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
   security_groups = ["${aws_security_group.wordpress_elb.id}"]
  }

  ingress {
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "wordpress_instance"
  }
}


#security group_for_ELB(incoming or outgoing traffic HTTP and HTTPS) 
resource "aws_security_group" "wordpress_elb" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
  description = "security-group-elb" 
  
  ingress {
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "wordpress_elb"
  }
}

#security group_for database(RDS)(incoming or outgoing traffic port_3306)
resource "aws_security_group" "wordpress_db" {
  vpc_id = "${aws_vpc.vpc_wordpress.id}"
  description = "security-group-db"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${aws_security_group.wordpress_instance.id}"]  
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  tags {
    Name = "wordpress_db"
  }
}
