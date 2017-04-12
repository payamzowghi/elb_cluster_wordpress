#create aws_elb resource(two availability_zones) for https and http
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
