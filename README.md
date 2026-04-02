# Citadel GPS Pipeline Terraform

Terraform deployment for the Citadel GPS pipeline in this repository.

## What It Deploys

- AWS Glue jobs for:
  - preprocessing
  - data-cleaning
  - staymove-extraction
  - trip-segmentation
  - footfall
  - optional orchestrator wrapper
- One Step Functions state machine for the branch flow:
  - preprocessing -> data-cleaning
  - parallel:
    - footfall
    - staymove-extraction -> trip-segmentation
- S3 uploads for Scala scripts, config, and optional JAR artifact.

## Layout

- `main.tf`, `variables.tf`, `backend.tf`
- `modules/glue_job` reusable Glue job module
- `modules/gps_mobility_pipeline/step_functions` state machine module
- `modules/assesment/s3_files` local artifact upload module
- `scripts/scala` Scala script placeholders for Glue script locations
- `scripts/config/config_pipeline.json`
- `scripts/jar/` local JAR staging directory

## Usage

1. Set backend:
```bash
terraform init -reconfigure -backend-config=config-dev.hcl
```

2. Plan/apply:
```bash
terraform plan -var-file=terraform.dev.tfvars
terraform apply -var-file=terraform.dev.tfvars
```

3. Start the state machine using `invoke.sh` or AWS Console.

Execution input must always include `glue_arguments.--BBOX`.
When bbox filtering is not needed, set it to an empty string:
```json
{
  "glue_arguments": {
    "--BBOX": ""
  }
}
```

The `data-cleaning` module already treats blank bbox as "do not filter", so this keeps the Step Functions definition simple while avoiding JSONPath failures.
