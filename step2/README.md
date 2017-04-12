# Step2:

## Create Cluster, Loadbalancer, and SSL_certification
  
- Create aws_launch_configuration, aws_autoscaling_group, template_file, aws_elb, and ssl_certification

1-aws_launch_configuration:
-A launch configuration is a template that an Auto Scaling group uses to launch EC2 instances
````
resource "aws_launch_configuration" "wordpress" {
  name_prefix                 = "wordpress_lc"
  image_id                    = "ami-a58d0dc5"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${aws_security_group.wordpress_instance.id    }"]
  associate_public_ip_address = true
  iam_instance_profile        = "assignments"
  user_data                   = "${data.template_file.user_data.rendered}"
   
lifecycle {
   create_before_destroy = true
 }
}
````
Note:

-Security group:A list of associated security group IDS

-Key_name: the name of Keypair

-Associate_public_ip_address:Associate a public ip address with an instance in a VPC.

-User_data:The user data to provide when launching the instance.

-Lifecycle:customizes the lifecycle behavior of the resource.


2-aws_autoscaling_group:

-Auto Scaling helps us ensure that we have the correct number of Amazon EC2 instances available to handle the load for your application.(cluster)
````
resource "aws_autoscaling_group" "wordpress" {         
  launch_configuration      = "${aws_launch_configuration.wordpress.id}"
  load_balancers            = ["${aws_elb.wordpress.name}"]
  name                      = "wordpress_AutoSG"       
  vpc_zone_identifier       = ["${aws_subnet.public_wordpress1.id}", "${aws_subnet.public_wordpress2.id}"]
  min_size                  = 2                        
  max_size                  = 4                        
  desired_capacity          = 2                        
  health_check_type         = "ELB"
  health_check_grace_period = 600
  force_delete              = true

tag {                                                
  key                 = "Name"                       
  value               = "wordpress_asg"              
  propagate_at_launch = true                         
 }                                                    
lifecycle {                                          
  create_before_destroy = true                       
 }                                                    
}
````
Note:

-Load_balancer:A list of load balancer names to add to the autoscaling group names.

-Vpc_zone_identifier:A list of subnet IDs to launch resources in.

-Desired_capacity:The number of Amazon EC2 instances that should be running in the group


3-template_file:

-The template_file data source, responsible for rendering text templates.It's really useful for bootstrap scripts.
````
data "template_file" "user_data" {                 
  template = "${file("files/wordpress_ubuntu.sh")}"
    
  vars {                                              
  db_address   = "${aws_db_instance.wordpress-db.address}"
  db_port      = "${aws_db_instance.wordpress-db.port}"
  db_user      = "${aws_db_instance.wordpress-db.username}" 
  db_password  = "${aws_db_instance.wordpress-db.password}" 
 }
}
````
Note:

-Path of bash file:"files/wordpress_ubuntu.sh")

-These vars are attributes of resources:db.port, db.address, db.password and, db.username as outputs of database for logging to MySQL

4-aws_elb:

-Elastic Load Balancing distributes incoming web application traffic across multiple EC2 instances, in multiple Availability Zones. This increases the fault tolerance and the High Availability of your applications.
````
resource "aws_elb" "wordpress" {
  name                 = "wordpress-elb"
  subnets              = ["${aws_subnet.public_wordpress1.id}", "${aws_subnet.public_wordpress2.id}"]
  security_groups      = ["${aws_security_group.wordpress_elb.id}"]
    
  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }
 
  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:iam::272462672480:server-certificate/elastic-beanstalk-x509"
  }
   
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 6
    timeout             = 4
    target              = "TCP:80"
    interval            = 80
  }
 }
````
Note:

-Subnet:A list of subnet IDs in different AZ to attach to the ELB.

-Listener:the HTTPS listener sends requests to the instances on port 443, communication from the load balancer to the instances is encrypted.we must deploy an SSL server certificate on your load balancer.

-Health_check:Elastic Load Balancing automatically checks the health of the registered webservers for the load balancer.(for this case send tcp with port 80)


5-ssl_certificate_id:

-for security issue, I created ssl certification key with openssl and use IAM API to upload a certification.The keys generated by terraform's resources will be stored unencrypted in the Terraform state file.

-Create your private key, use the openssl genrsa command:
````
openssl genrsa 2048 > privatekey.pem
````
-To create a CSR, use the openssl req command:
````
openssl req -new -key privatekey.pem -out csr.pem
````
-Create a public certificate named server.crt that is valid for 365 days:
````
openssl x509 -req -days 365 -in csr.pem -signkey privatekey.pem -out server.crt
````
-Use the IAM API to upload a certificate with AWS CLI
````
aws iam upload-server-certificate --server-certificate-name ExampleCertificate
                                    --certificate-body file://Certificate.pem
                                    --certificate-chain file://CertificateChain.pem
                                    --private-key file://PrivateKey.pem
```` 
When the preceding command is successful, it returns metadata about the uploaded certificate, include its ARN, expiration date, and more.

-To use the IAM API to retrieve a certificate with AWS CLI
````
aws iam get-server-certificate --server-certificate-name ExampleCertificate
````
-To use the IAM API to delete a server certificate with AWS CLI
````
aws iam delete-server-certificate --server-certificate-name ExampleCertificate
````

