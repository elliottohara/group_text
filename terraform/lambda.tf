
resource "aws_s3_bucket" "deployment" {
  bucket = "${var.deployment_bucket}"
  versioning {
    enabled = true
  }
}
locals {
  lambda_distro = "${path.module}/../dst/lambda.zip"
  s3_key = "${var.name_prefix}.${filemd5(local.lambda_distro)}.zip"
}
resource "aws_s3_bucket_object" "lambda" {
  bucket = "${aws_s3_bucket.deployment.bucket}"
  key = "${local.s3_key}"
  source = "${path.module}/../dst/lambda.zip"

}

resource "aws_lambda_function" "message_sender" {
  function_name = "${var.name_prefix}-message-sender"
  handler = "lambdas.send_message"
  runtime = "python3.7"
  s3_bucket = "${aws_s3_bucket_object.lambda.bucket}"
  s3_key = "${aws_s3_bucket_object.lambda.key}"
  role = "${aws_iam_role.lambda_role.arn}"
  environment {
    variables = {
      APP_ID = "${aws_pinpoint_app.app.id}"
      APP_NAME = "${var.default_app_name}"
      TABLE = "${aws_dynamodb_table.app.name}"
    }
  }
}

resource "aws_lambda_permission" "message_sender" {
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.message_sender.function_name}"
  principal = "sns.amazonaws.com"
  statement_id = "AllowExecutionFromSNS"
  source_arn = "${aws_sns_topic.message.arn}"
}

resource "aws_sns_topic_subscription" "message_sender" {
  endpoint = "${aws_lambda_function.message_sender.arn}"
  protocol = "lambda"
  topic_arn = "${aws_sns_topic.message.arn}"
}

