locals {
  dashboard_name = "${var.project_name}-dashboard"
}

resource "aws_cloudwatch_dashboard" "waf_dashboard" {
  dashboard_name = local.dashboard_name
  dashboard_body = jsonencode({
    widgets = [
      {
        "type" : "metric",
        "x" : 0, "y" : 0, "width" : 12, "height" : 6,
        "properties" : {
          "title" : "WAF Allowed vs Blocked",
          "region" : var.aws_region,
          "metrics" : [
            ["AWS/WAFV2", "AllowedRequests", "WebACL", aws_wafv2_web_acl.web_acl.name, { "stat" : "Sum" }],
            [".", "BlockedRequests", ".", ".", { "stat" : "Sum" }]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "period" : 300
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 0, "width" : 12, "height" : 6,
        "properties" : {
          "title" : "ALB HTTP 4xx/5xx",
          "region" : var.aws_region,
          "metrics" : [
            ["AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", aws_lb.app_lb.arn_suffix, { "stat" : "Sum" }],
            [".", "HTTPCode_ELB_5XX_Count", ".", ".", { "stat" : "Sum" }]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "period" : 300
        }
      }
    ]
  })
}
