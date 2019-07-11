data "aws_iam_policy_document" "lambda_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = [
        "lambda.amazonaws.com",
      ]

      type = "Service"
    }
  }
}
locals {
  required_lambda_roles = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]
}


resource "aws_iam_role" "lambda_role" {
  name               = "${var.name_prefix}-lambda-role"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_role.json}"
}


resource "aws_iam_role_policy_attachment" "built_ins" {
  count = "${length(local.required_lambda_roles)}"
  policy_arn = "${element(local.required_lambda_roles, count.index)}"
  role = "${aws_iam_role.lambda_role.name}"
}


data "aws_iam_policy_document" "send_message" {
  statement {
    effect = "Allow"
    actions = [
      "mobiletargeting:SendMessages"]
    # TODO: get proper arn
    resources = ["*"]
    sid = "AllowMobileSendMessage"
  }

}



resource "aws_iam_role_policy" "send_message" {
  policy = "${data.aws_iam_policy_document.send_message.json}"
  role = "${aws_iam_role.lambda_role.id}"
}

data "aws_iam_policy_document" "dynamo" {
  statement {
    sid = "AllowAccessToAppTable"
    resources = ["${aws_dynamodb_table.app.arn}"]
    effect = "Allow"
    actions = ["dynamodb:Query"]
  }
}

resource "aws_iam_role_policy" "dynamo" {
  policy = "${data.aws_iam_policy_document.dynamo.json}"
  role = "${aws_iam_role.lambda_role.id}"
}