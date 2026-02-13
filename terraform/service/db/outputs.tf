output "table_name" {
  value = aws_dynamodb_table.snack_table.name
}

output "table_arn" {
  value = aws_dynamodb_table.snack_table.arn
}
