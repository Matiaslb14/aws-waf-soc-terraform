output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.waf_alerts.arn
}

output "cloudwatch_dashboard" {
  value = aws_cloudwatch_dashboard.waf_dashboard.dashboard_name
}
