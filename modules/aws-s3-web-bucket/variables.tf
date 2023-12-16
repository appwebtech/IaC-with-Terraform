
variable "s3_bucket-name" {
  type        = string
  description = "s3 bucket name to be created"
}


variable "resource-tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied on bucket resource"
}
