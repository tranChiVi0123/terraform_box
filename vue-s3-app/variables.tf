variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "project" {
  description = "The project name to use for unique resource naming"
  default     = "vue-s3-web"
  type        = string
}

variable "environment" {
  type        = string
  default     = "test"
  description = "Target environment"
}
