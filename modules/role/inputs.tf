
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "allowed_zones" {
  type = any
  default = ""
  description = "DNS ZONES ALLOWED"
}


variable "oidc"{
  default = ""
}

variable "role_name" {
  
  default     = ""
  description = "Name of the role"
}

variable "policy_name"{
  default = "iam_policy"
}