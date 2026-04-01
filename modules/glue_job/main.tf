locals {
  glue_log_group_prefix = "/aws-glue/jobs/${var.job_name}"
}

resource "aws_cloudwatch_log_group" "error" {
  name              = "${local.glue_log_group_prefix}/error"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "output" {
  name              = "${local.glue_log_group_prefix}/output"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_glue_job" "this" {
  name     = var.job_name
  role_arn = var.role_arn

  command {
    name            = "glueetl"
    script_location = var.script_location
  }

  default_arguments = {
    "--job-language"                 = "scala"
    "--class"                        = var.class
    "--extra-jars"                   = var.extra_jars
    "--custom-logGroup-prefix"       = local.glue_log_group_prefix
    "--custom-logStream-prefix"      = var.job_name
    "--enable-metrics"               = ""
    "--enable-observability-metrics" = "true"
    "--job-log-level"                = "INFO"
    "--S3_BUCKET"                    = var.s3_bucket
    "--JAR_PREFIX"                   = var.jar_prefix
    "--enable-spark-ui"              = "true"
  }

  glue_version      = "5.0"
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers
  description       = var.description

  execution_property {
    max_concurrent_runs = var.max_concurrent_runs
  }

  tags = var.tags
}

