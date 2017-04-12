#address of ELB
output "elb_address" {
  value = "${aws_elb.wordpress.dns_name}"
}

