resource "aws_s3_bucket" "app" {
  bucket = "${local.prefix}-${random_integer.bucket_suffix.result}"
}

resource "random_integer" "bucket_suffix" {
  min = 100000
  max = 999999
}

### Bucket access

resource "aws_s3_bucket_public_access_block" "allow_spublic_access" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "template_file" "bucket_policy" {
  template = file("./templates/bucket-policy/bucket-policy.json.tpl")
  vars = {
    bucket_name = aws_s3_bucket.app.id
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.app.id
  policy = data.template_file.bucket_policy.rendered
}

### Static website configuration

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.app.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

### Bucket objects

module "template_files" {
  source   = "hashicorp/dir/template"
  base_dir = "site/"
}

resource "aws_s3_object" "app-objects" {
  for_each     = module.template_files.files
  bucket       = aws_s3_bucket.app.id
  key          = each.key
  content_type = each.value.content_type
  source       = each.value.source_path
  content      = each.value.content
}
