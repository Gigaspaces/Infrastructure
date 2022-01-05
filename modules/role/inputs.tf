
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