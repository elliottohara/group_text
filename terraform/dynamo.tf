resource "aws_dynamodb_table" "app" {
  hash_key = "Channel"
  range_key = "Number"
  name = "${var.name_prefix}"
  write_capacity = 5
  read_capacity = 5
  attribute {
    name = "Channel"
    type = "S"
  }
  attribute {
    name = "Number"
    type = "S"
  }
}
