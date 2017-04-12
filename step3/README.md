# Step3:

## Create Database and Monitoring Database
  
- Create aws_db_subnet_group, aws_db_instance, and aws_cloudwatch_metric_alarm

1-aws_db_subnet_group:

-Provides an RDS DB subnet group resource.
````
resource "aws_db_subnet_group" "wordpress_db_subnet_group" {     
  name       = "wordpress_db_subnet_group"
  subnet_ids = ["${aws_subnet.DB_wordpress1.id}", "${aws_subnet.DB_wordpress2.id}"]
    
    tags {
      Name = "My DB subnet group"
    }
}
````

2-Create aws_db_instance:

-Provides an RDS instance resource. A DB instance is an isolated database environment in the cloud. A DB instance can contain multiple user-created databases.
````
resource "aws_db_instance" "wordpress-db" {
  allocated_storage       = 5
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.6.27"
  instance_class          = "db.t2.micro"
  name                    = "mydb"
  username                = "wordpress_db"
  password                = "${var.db_password}"
  backup_retention_period = "30"
  backup_window           = "08:03-08:33"
  maintenance_window      = "Mon:00:00-Mon:03:00"
  multi_az                = true
  vpc_security_group_ids  = ["${aws_security_group.wordpress_db.i    d}"]
  db_subnet_group_name    = "${aws_db_subnet_group.wordpress_db_s    ubnet_group.id}"
  parameter_group_name    = "default.mysql5.6"
  apply_immediately       = true
}
````
Note:

-Allocated_storage:The allocated storage in gigabytes.

-Engine:The database engine to use.(MySQL,MariaDB, and etc)

-Engine_version:The engine version to use.

-Instance_class:The instance type of the RDS instance.

-Backup_retention_period:The days to retain backups for.

-Maintenance_window:The window to perform maintenance in.

-Apply_immediately:Specifies whether any database modifications are applied immediately, or during the next maintenance window.

-Password: for security, I didn't put password in variable file directly.I use TF_VAR_db_password environment variable:
````
export TF_VAR_db_password="(YOUR_DB_PASSWORD)"
````

2-Create aws_cloudwatch_metric_alarm(without action):

-Provides a CloudWatch Metric Alarm resource.
````
resource "aws_cloudwatch_metric_alarm" "wordpress_monitor_RDS" {
  alarm_name                = "wordpress_rds_FreeStorageAlarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"    
  metric_name               = "FreeStorageSpace"
  namespace                 = "AWS/RDS"
  period                    = "120"  
  statistic                 = "Average"
  threshold                 = "80"   
  actions_enabled           = true   
  alarm_description         = "This metric monitor rds free storage"
}                                    
````
Note:

-Comparison_operator:The arithmetic operation to use when comparing the specified Statistic and Threshold.

-Evaluation_periods:The number of periods over which data is compared to the specified threshold.

-Metric_name:The name for the alarm's associated metric.

-Namespace:The namespace for the alarm's associated metric. 

-Period:The period in seconds over which the specified statistic is applied.

-Statistc:The statistic to apply to the alarm's associated metric. 

-Threshold:The value against which the specified statistic is compared.

-Actions_enabled:Indicates whether or not actions should be executed during any changes to the alarm's state.

