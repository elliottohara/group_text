resource "aws_pinpoint_app" "app" {
  name = "${var.name_prefix}-app"

}
resource "aws_pinpoint_sms_channel" "message" {
  application_id = "${aws_pinpoint_app.app.id}"
}
