
resource "aws_sns_topic" "message" {
  name = "${var.name_prefix}-messages"
}
