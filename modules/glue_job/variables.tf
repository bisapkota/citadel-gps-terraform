variable "job_name" {
  description = "Name of the Glue job"
  type        = string
}

variable "role_arn" {
  description = "IAM role ARN for the Glue job"
  type        = string
}

variable "script_location" {
  description = "S3 URI of the Glue script"
  type        = string
}

variable "class" {
  description = "Fully qualified Scala/Java class entry point"
  type        = string
}

variable "extra_jars" {
  description = "S3 URI of extra JARs to attach"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket passed to the job as --S3_BUCKET"
  type        = string
}

variable "jar_prefix" {
  description = "S3 prefix passed to the job as --JAR_PREFIX"
  type        = string
}

variable "number_of_workers" {
  description = "Number of workers"
  type        = number
  default     = 2
}

variable "worker_type" {
  description = "Glue worker type"
  type        = string
  default     = "G.1X"
}

variable "description" {
  description = "Human-readable description of the job"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the Glue job"
  type        = map(string)
  default     = {}
}

variable "max_concurrent_runs" {
  description = "Maximum number of concurrent runs allowed for this Glue job"
  type        = number
  default     = 1
}

