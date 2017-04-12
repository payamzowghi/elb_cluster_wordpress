# Step1:

## Create Network and Security Infrastructure
  
- Create aws_vpc, aws_internet_gateway, aws_route_internet_access, aws_route_table_association, aws_route_table, aws_subnet.

1-vpc:

-Create aws_vpc in region us_west_2 with cidr="172.16.0.0/16"

2-Create aws_internet_gateway to allow communication between instances in my VPC and the Internet

3-Create aws_route_internet_access to control the routing for public subnet

````
source "aws_route_table" "rt_public_wordpress" {
   vpc_id = "${aws_vpc.vpc_wordpress.id}"
  
   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig_wordpress.id}"
   }
     
   tags {
     Name = "rt_public_wordpress"
   }
}
````

4-Create ws_route_table_association to associate subnets with a route table.(Each subnet in my VPC must be associated with a route table)

-aws_route_table_association_public1

-aws_route_table_association_public2

-aws_route_table_association_db1

-aws_route_table_association_db2

5-Create aws_route_table contains a set of rules to determine network traffic

-The aws_route_table_public

-The aws_route_table_db

6-Create aws_subnet(public and private) and add subnet to different AZ(because vpc spans all the AZ,By launching instances in separate Availability Zones, I can protect my applications from the failure of a single location)

-Create and add public subnet in AZ_us_west_2a

-Create and add public subnet in AZ_us_west_2b

-Create and add private subnet in AZ_us_west_2a(database) 

-Create and add private subnet in AZ_us_west_2b(database)
````
resource "aws_subnet" "DB_wordpress2" {
   vpc_id            = "${aws_vpc.vpc_wordpress.id}"
   availability_zone = "us-west-2b"
   cidr_block        = "172.16.5.0/24"
  
   tags {               
     Name = "${var.name-db}-db2"
   }
 }
````

Note:

-Private subnet has no connection with outside(internet) for database(RDS).we can use MySQL Workbench, MySQL utility and, SSH Tunneling to connecting to RDS. 


7-Create aws_network_acl to control inbound and outbound traffic for my subnets

8-Create aws_security_group to control inbound and outbound traffic for my resources(ELB,DRS,EC2 instance)

-Security group_for EC2 instance(incoming or outgoing traffic for HTTP and SSH)
````
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
````
Note:

-for security issue,Use security group as a source(ELB security group)

-Security group_for_ELB(incoming or outgoing traffic for HTTPS and HTTP)
````
iingress {
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
````
-Security group_for database(RDS)(incoming or outgoing traffic for port 3306)
````
ingress {         
  from_port = 3306
  to_port = 3306                                                          
  protocol = "tcp"
  security_groups = ["${aws_security_group.wordpress_instance.id}"]  
  }
````
Note: 
-for security issue,Use security group as a source(RDS security group).Control traffic between webserver and database in port 3306
 
