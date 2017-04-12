#use AWS as provider
provider "aws" {
  region = "${var.region}"
}

#create_cluster and run user_data after boot EC2
resource "aws_launch_configuration" "wordpress" {
  name_prefix                 = "wordpress_launch"
  image_id                    = "ami-a58d0dc5"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${aws_security_group.wordpress_instance.id}"]
  associate_public_ip_address = true
  iam_instance_profile        = "assignments"
  user_data                   = "${data.template_file.user_data.rendered}"  

lifecycle {
   create_before_destroy = true
 }
}

#ASG will run between 2_and 4_EC2 Instances
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

#user_data for install wordpress_ubuntu.sh in instances
data "template_file" "user_data" {
  template = "${file("files/wordpress_ubuntu.sh")}"

  vars {
  db_address   = "${aws_db_instance.wordpress-db.address}"
  db_port      = "${aws_db_instance.wordpress-db.port}"
  db_user      = "${aws_db_instance.wordpress-db.username}" 
  db_password  = "${aws_db_instance.wordpress-db.password}" 
 }
}
