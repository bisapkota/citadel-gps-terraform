variable "glue_job_role_arn" {
  description = "IAM role ARN for the Step Functions state machine"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "preprocessing_job" {
  description = "Name of preprocessing Glue job"
  type        = string
}

variable "datacleaning_job" {
  description = "Name of data-cleaning Glue job"
  type        = string
}

variable "footfall_job" {
  description = "Name of footfall Glue job"
  type        = string
}

variable "staymove_job" {
  description = "Name of staymove Glue job"
  type        = string
}

variable "trip_segmentation_job" {
  description = "Name of trip-segmentation Glue job"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

