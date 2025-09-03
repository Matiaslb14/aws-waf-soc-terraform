# AWS WAF + Advanced Detection (Cloud SOC Lab)

🚀 Cloud Security lab using **Terraform + AWS** to deploy a protected infrastructure with **WAF**, **ALB**, **EC2**, **CloudWatch Dashboards**, and **SNS Alerts**.

---

## 📌 Architecture
- **VPC** with public subnets
- **Application Load Balancer (ALB)**
- **EC2 (Ubuntu + Nginx demo page)**
- **AWS WAF (Managed Rules: SQLi, XSS, KnownBadInputs)**
- **CloudWatch Dashboard** (Allowed vs Blocked, 4xx/5xx metrics)
- **SNS Alerts** (email notification on blocked traffic / ALB errors)

---

## ⚡ Deployment

```bash
# Initialize
terraform init

# Validate
terraform validate

# Apply (change email to your own)
terraform apply -auto-approve \
  -var alert_email="youremail@example.com" \
  -var aws_region="us-east-1" \
  -var aws_profile="your-profile"

✅ Confirm the SNS subscription email you receive.
✅ After ~5 minutes, the ALB, EC2, WAF, and Dashboard will be available.

🔎 Testing WAF

Once deployed, Terraform outputs the ALB DNS. Example:

http://waf-soc-alb-XXXXXXXX.us-east-1.elb.amazonaws.com

Run some test payloads:

# SQL Injection attempt
curl -i "http://ALB-DNS/?q=%27%20OR%201%3D1%20--%20-"

# XSS attempt
curl -i "http://ALB-DNS/%3Cscript%3Ealert(1)%3C%2Fscript%3E"

# SQLi with UNION
curl -i "http://ALB-DNS/?user=admin&pass=%27%20UNION%20SELECT%201%2C2%20--%20-"

👉 Expected: HTTP 403 Forbidden and the requests logged as Blocked in WAF.

📊 Observability

WAF Console → WebACL → Sampled Requests → shows blocked traffic.

CloudWatch → Dashboard (waf-soc-dashboard) → graphs for blocked vs allowed requests.

SNS Email Alerts → triggered when WAF blocks traffic or ALB has 5xx spikes.

.

🧹 Destroy

To avoid costs:

terraform destroy -auto-approve \
  -var alert_email="youremail@example.com" \
  -var aws_region="us-east-1" \
  -var aws_profile="your-profile"

## 📸 Demo Screenshots

![Blocked Requests](https://raw.githubusercontent.com/Matiaslb14/aws-waf-soc-terraform/main/images/waf-blocked-requests.png)

![WAF Dashboard](https://raw.githubusercontent.com/Matiaslb14/aws-waf-soc-terraform/main/images/waf-dashboard.png)

![curl tests](https://raw.githubusercontent.com/Matiaslb14/aws-waf-soc-terraform/main/images/waf-curl-tests.png)

🔐 Skills Demonstrated

Terraform IaC for AWS Security

Cloud SOC mindset (WAF + Monitoring + Alerts)

DevSecOps pipeline for secure infra as code
