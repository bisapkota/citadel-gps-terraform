variable "glue_script_prefix" {
  description = "S3 prefix for Glue scripts"
  type        = string
}

variable "java_pipeline_jar_prefix" {
  description = "S3 prefix for Java JAR files"
  type        = string
}

variable "java_pipeline_jar_name" {
  description = "JAR file name to upload"
  type        = string
}

variable "s3_bucket_name" {
  type        = string
  description = "Target S3 bucket"
}

variable "glue_script_source_dir" {
  type        = string
  description = "Local path containing scripts/config/jar assets"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

