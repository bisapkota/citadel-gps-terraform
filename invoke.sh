#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-ap-northeast-1}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
S3_BUCKET="${S3_BUCKET:-lm-sandbox-pipeline-citadel}"
RUN_DATE="${RUN_DATE:-$(date +%F)}"
TIME_ZONE="${TIME_ZONE:-Asia/Tokyo}"

STATE_MACHINE_NAME="citadel-gps-mobility-pipeline-${ENVIRONMENT}"
STATE_MACHINE_ARN="$(aws stepfunctions list-state-machines --region "${AWS_REGION}" --query "stateMachines[?name=='${STATE_MACHINE_NAME}'].stateMachineArn | [0]" --output text)"

if [[ -z "${STATE_MACHINE_ARN}" || "${STATE_MACHINE_ARN}" == "None" ]]; then
  echo "State machine not found: ${STATE_MACHINE_NAME}" >&2
  exit 1
fi

INPUT_JSON="$(cat <<JSON
{
  "glue_arguments": {
    "--S3_BUCKET": "${S3_BUCKET}",
    "--RUN_DATE": "${RUN_DATE}",
    "--TIME_ZONE": "${TIME_ZONE}",
    "--RAW_INPUT_PATH": "s3://${S3_BUCKET}/raw/",
    "--PREPROCESS_OUTPUT_PATH": "s3://${S3_BUCKET}/preprocessed/${RUN_DATE}/",
    "--DC_OUTPUT_PATH": "s3://${S3_BUCKET}/data-cleaning/${RUN_DATE}/",
    "--STAYMOVE_OUTPUT_PATH": "s3://${S3_BUCKET}/staymove/${RUN_DATE}/",
    "--TRIP_SEGMENTATION_OUTPUT_PATH": "s3://${S3_BUCKET}/trip-segmentation/${RUN_DATE}/",
    "--FOOTFALL_OUTPUT_PATH": "s3://${S3_BUCKET}/footfall/${RUN_DATE}/",
    "--POI_PATH": "s3://${S3_BUCKET}/poi/poi.csv"
  }
}
JSON
)"

aws stepfunctions start-execution \
  --region "${AWS_REGION}" \
  --state-machine-arn "${STATE_MACHINE_ARN}" \
  --input "${INPUT_JSON}"

