provider "aws" {
  region = var.aws_region
}

locals {
  tags = {
    Terraform   = "true"
    Team        = "data-pipeline-unit"
    Environment = var.environment
    Project     = "citadel-gps"
  }

  glue_script_prefix_env = "${trim(var.glue_script_prefix, "/")}/${var.environment}"
  jar_prefix_env         = "${trim(var.java_pipeline_jar_prefix, "/")}/${var.environment}"
  jar_s3_uri             = "s3://${var.s3_bucket}/${local.jar_prefix_env}/${var.java_pipeline_jar_filename}"
}

module "job_preprocessing" {
  source = "./modules/glue_job"

  job_name            = "citadel-gps-preprocessing-${var.environment}"
  role_arn            = var.glue_job_role_arn
  script_location     = "s3://${var.s3_bucket}/${local.glue_script_prefix_env}/scala/GluePreprocess.scala"
  class               = "com.locationmind.preprocessing.GluePreprocess"
  extra_jars          = local.jar_s3_uri
  s3_bucket           = var.s3_bucket
  jar_prefix          = local.jar_prefix_env
  number_of_workers   = var.number_of_workers
  worker_type         = var.worker_type
  max_concurrent_runs = var.max_concurrent_runs
  description         = "GPS preprocessing entrypoint"
  tags                = local.tags
}

module "job_datacleaning" {
  source = "./modules/glue_job"

  job_name            = "citadel-gps-datacleaning-${var.environment}"
  role_arn            = var.glue_job_role_arn
  script_location     = "s3://${var.s3_bucket}/${local.glue_script_prefix_env}/scala/GlueDataCleaning.scala"
  class               = "com.locationmind.datacleaning.GlueDataCleaning"
  extra_jars          = local.jar_s3_uri
  s3_bucket           = var.s3_bucket
  jar_prefix          = local.jar_prefix_env
  number_of_workers   = var.number_of_workers
  worker_type         = var.worker_type
  max_concurrent_runs = var.max_concurrent_runs
  description         = "GPS data-cleaning entrypoint"
  tags                = local.tags
}

module "job_staymove" {
  source = "./modules/glue_job"

  job_name            = "citadel-gps-staymove-${var.environment}"
  role_arn            = var.glue_job_role_arn
  script_location     = "s3://${var.s3_bucket}/${local.glue_script_prefix_env}/scala/GlueStayMove.scala"
  class               = "com.locationmind.staymoveextraction.GlueStayMove"
  extra_jars          = local.jar_s3_uri
  s3_bucket           = var.s3_bucket
  jar_prefix          = local.jar_prefix_env
  number_of_workers   = var.number_of_workers
  worker_type         = var.worker_type
  max_concurrent_runs = var.max_concurrent_runs
  description         = "GPS staymove entrypoint"
  tags                = local.tags
}

module "job_trip_segmentation" {
  source = "./modules/glue_job"

  job_name            = "citadel-gps-trip-segmentation-${var.environment}"
  role_arn            = var.glue_job_role_arn
  script_location     = "s3://${var.s3_bucket}/${local.glue_script_prefix_env}/scala/GlueTripSegmentation.scala"
  class               = "com.locationmind.tripsegmentation.GlueTripSegmentation"
  extra_jars          = local.jar_s3_uri
  s3_bucket           = var.s3_bucket
  jar_prefix          = local.jar_prefix_env
  number_of_workers   = var.number_of_workers
  worker_type         = var.worker_type
  max_concurrent_runs = var.max_concurrent_runs
  description         = "GPS trip segmentation entrypoint"
  tags                = local.tags
}

module "job_footfall" {
  source = "./modules/glue_job"

  job_name            = "citadel-gps-footfall-${var.environment}"
  role_arn            = var.glue_job_role_arn
  script_location     = "s3://${var.s3_bucket}/${local.glue_script_prefix_env}/scala/GlueFootfall.scala"
  class               = "com.locationmind.footfall.GlueFootfall"
  extra_jars          = local.jar_s3_uri
  s3_bucket           = var.s3_bucket
  jar_prefix          = local.jar_prefix_env
  number_of_workers   = var.number_of_workers
  worker_type         = var.worker_type
  max_concurrent_runs = var.max_concurrent_runs
  description         = "GPS footfall entrypoint"
  tags                = local.tags
}

module "job_pipeline_orchestrator" {
  source = "./modules/glue_job"

  job_name            = "citadel-gps-orchestrator-${var.environment}"
  role_arn            = var.glue_job_role_arn
  script_location     = "s3://${var.s3_bucket}/${local.glue_script_prefix_env}/scala/GluePipeline.scala"
  class               = "com.locationmind.orchestrator.GluePipeline"
  extra_jars          = local.jar_s3_uri
  s3_bucket           = var.s3_bucket
  jar_prefix          = local.jar_prefix_env
  number_of_workers   = var.number_of_workers
  worker_type         = var.worker_type
  max_concurrent_runs = var.max_concurrent_runs
  description         = "Pipeline orchestrator wrapper"
  tags                = local.tags
}

module "files" {
  source = "./modules/assesment/s3_files"

  java_pipeline_jar_prefix = local.jar_prefix_env
  java_pipeline_jar_name   = var.java_pipeline_jar_filename
  s3_bucket_name           = var.s3_bucket
  glue_script_source_dir   = "${path.root}/scripts"
  glue_script_prefix       = local.glue_script_prefix_env
  tags                     = local.tags
}

module "gps_orchestrator" {
  source = "./modules/gps_mobility_pipeline/step_functions"

  glue_job_role_arn     = var.glue_job_role_arn
  environment           = var.environment
  preprocessing_job     = module.job_preprocessing.job_name
  datacleaning_job      = module.job_datacleaning.job_name
  footfall_job          = module.job_footfall.job_name
  staymove_job          = module.job_staymove.job_name
  trip_segmentation_job = module.job_trip_segmentation.job_name
  tags                  = local.tags
}

