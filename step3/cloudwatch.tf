#cluod_watch_for FreeStorageSpace_RDS
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
