variable "project_name" {
  type        = string
  default     = "waf-soc"
  description = "Nombre base para recursos"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type        = string
  default     = null
  description = "Perfil de credenciales AWS CLI (opcional)"
}

variable "alert_email" {
  type        = string
  description = "Email para suscripción SNS (requiere confirmación)"
}

variable "instance_key_name" {
  type        = string
  default     = null
  description = "Nombre de key pair para SSH (opcional)"
}
