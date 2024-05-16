// *************************************** //
// ******** Environment Variables ******** //
// *************************************** //
//Region
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

// *************************************** //
// ********* S3 Bucket Variables ********* //
// *************************************** //


variable "bucket_name" {
  description = "AWS S3 bucket name"
  type        = string
  default     = "raw_s3_bucket"
}

variable "environment" {
  description = "Defines the environment of the infrastructure"
  type        = string
}