variable "name_prefix" {
  description = "A unique Identifier to prefix all resources with"
  default = "group-text"
}
variable "aws_profile" {
  description = "The AWS profile to use"
  default = "personal"
}
variable "deployment_bucket" {
  default = "elliotts-deployment-bucket"
}
variable "default_app_name" {
  default = "app"
}