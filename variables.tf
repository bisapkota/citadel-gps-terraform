variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-northeast-1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket for pipeline assets and data"
  type        = string
}

variable "glue_job_role_arn" {
  description = "IAM role ARN used by Glue jobs and Step Functions"
  type        = string
}

variable "glue_script_prefix" {
  description = "S3 prefix for Glue scripts"
  type        = string
  default     = "data_pipelines"
}

variable "java_pipeline_jar_prefix" {
  description = "S3 prefix for pipeline JAR"
  type        = string
  default     = "java/jar"
}

variable "java_pipeline_jar_filename" {
  description = "Pipeline JAR file name"
  type        = string
  default     = "citadel-gps-data-processing.jar"
}

variable "number_of_workers" {
  description = "Default number of Glue workers"
  type        = number
  default     = 2
}

variable "worker_type" {
  description = "Glue worker type"
  type        = string
  default     = "G.1X"
}

variable "max_concurrent_runs" {
  description = "Default max concurrent runs per Glue job"
  type        = number
  default     = 1
}

