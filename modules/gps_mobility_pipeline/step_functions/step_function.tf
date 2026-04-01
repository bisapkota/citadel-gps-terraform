resource "aws_sfn_activity" "manual_approval" {
  name = "citadel-gps-pipeline-manual-approval-${var.environment}"
  tags = var.tags
}

resource "aws_sfn_state_machine" "gps_mobility_pipeline" {
  name     = "citadel-gps-mobility-pipeline-${var.environment}"
  role_arn = var.glue_job_role_arn
  tags     = var.tags

  definition = jsonencode({
    Comment = "GPS mobility pipeline: preprocessing -> data-cleaning -> parallel(footfall, staymove->trip-segmentation)"
    StartAt = "Preprocessing"
    States = {
      Preprocessing = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = var.preprocessing_job
          Arguments = {
            "--S3_BUCKET.$"   = "$.glue_arguments.--S3_BUCKET"
            "--INPUT_PATH.$"  = "$.glue_arguments.--RAW_INPUT_PATH"
            "--OUTPUT_PATH.$" = "$.glue_arguments.--PREPROCESS_OUTPUT_PATH"
            "--TIME_ZONE.$"   = "$.glue_arguments.--TIME_ZONE"
          }
        }
        ResultPath = "$.PreprocessingResult"
        Next       = "DataCleaning"
      }

      DataCleaning = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = var.datacleaning_job
          Arguments = {
            "--S3_BUCKET.$"   = "$.glue_arguments.--S3_BUCKET"
            "--INPUT_PATH.$"  = "$.glue_arguments.--PREPROCESS_OUTPUT_PATH"
            "--OUTPUT_PATH.$" = "$.glue_arguments.--DC_OUTPUT_PATH"
            "--TIME_ZONE.$"   = "$.glue_arguments.--TIME_ZONE"
            "--BBOX.$"        = "$.glue_arguments.--BBOX"
          }
        }
        ResultPath = "$.DataCleaningResult"
        Next       = "ParallelAfterCleaning"
      }

      ParallelAfterCleaning = {
        Type       = "Parallel"
        ResultPath = "$.ParallelResults"
        Next       = "PipelineSuccess"
        Branches = [
          {
            StartAt = "Footfall"
            States = {
              Footfall = {
                Type     = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                  JobName = var.footfall_job
                  Arguments = {
                    "--S3_BUCKET.$"   = "$.glue_arguments.--S3_BUCKET"
                    "--INPUT_PATH.$"  = "$.glue_arguments.--DC_OUTPUT_PATH"
                    "--OUTPUT_PATH.$" = "$.glue_arguments.--FOOTFALL_OUTPUT_PATH"
                    "--POI_PATH.$"    = "$.glue_arguments.--POI_PATH"
                    "--TIME_ZONE.$"   = "$.glue_arguments.--TIME_ZONE"
                  }
                }
                ResultPath = "$.FootfallResult"
                End        = true
              }
            }
          },
          {
            StartAt = "StayMoveExtraction"
            States = {
              StayMoveExtraction = {
                Type     = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                  JobName = var.staymove_job
                  Arguments = {
                    "--S3_BUCKET.$"   = "$.glue_arguments.--S3_BUCKET"
                    "--INPUT_PATH.$"  = "$.glue_arguments.--DC_OUTPUT_PATH"
                    "--OUTPUT_PATH.$" = "$.glue_arguments.--STAYMOVE_OUTPUT_PATH"
                    "--TIME_ZONE.$"   = "$.glue_arguments.--TIME_ZONE"
                  }
                }
                ResultPath = "$.StayMoveResult"
                Next       = "TripSegmentation"
              }

              TripSegmentation = {
                Type     = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                  JobName = var.trip_segmentation_job
                  Arguments = {
                    "--S3_BUCKET.$"   = "$.glue_arguments.--S3_BUCKET"
                    "--INPUT_PATH.$"  = "$.glue_arguments.--STAYMOVE_OUTPUT_PATH"
                    "--OUTPUT_PATH.$" = "$.glue_arguments.--TRIP_SEGMENTATION_OUTPUT_PATH"
                    "--TIME_ZONE.$"   = "$.glue_arguments.--TIME_ZONE"
                  }
                }
                ResultPath = "$.TripSegmentationResult"
                End        = true
              }
            }
          }
        ]
        Catch = [
          { ErrorEquals = ["States.ALL"], Next = "JobFailed" }
        ]
      }

      PipelineSuccess = {
        Type = "Succeed"
      }

      JobFailed = {
        Type  = "Fail"
        Error = "GlueJobFailed"
        Cause = "One or more Glue jobs failed."
      }
    }
  })
}

