locals {
  pipeline_jar_source = abspath("${var.glue_script_source_dir}/jar/${var.java_pipeline_jar_name}")
  pipeline_jar_key    = "${trim(var.java_pipeline_jar_prefix, "/")}/${var.java_pipeline_jar_name}"
}

resource "aws_s3_object" "pipeline_jar" {
  bucket       = var.s3_bucket_name
  key          = local.pipeline_jar_key
  source       = local.pipeline_jar_source
  source_hash  = filemd5(local.pipeline_jar_source)
  content_type = "application/java-archive"
  tags         = var.tags
}

resource "aws_s3_object" "glue_script" {
  for_each = toset([
    for f in fileset(var.glue_script_source_dir, "**") :
    f
    if can(regex("\\.(py|scala|json|pbf|csv|jar)$", f))
  ])

  bucket      = var.s3_bucket_name
  key         = "${var.glue_script_prefix}/${each.value}"
  source      = "${var.glue_script_source_dir}/${each.value}"
  source_hash = filemd5("${var.glue_script_source_dir}/${each.value}")
  tags        = var.tags
}

