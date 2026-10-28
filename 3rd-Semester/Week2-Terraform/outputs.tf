
output "vpc_id" {
  description = "ID of the project VPC"
  value       = aws_vpc.main.id
}

output "ec2_instance_ids" {
  description = "IDs of all EC2 instances"
  value       = aws_instance.web[*].id
}

output "ec2_public_ips" {
  description = "Public IP addresses of all EC2 instances"
  value       = aws_instance.web[*].public_ip
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.app_bucket.bucket
}

output "cloudwatch_alarm_created" {
  description = "Whether the CloudWatch alarm is configured"
  value       = length(aws_cloudwatch_metric_alarm.cpu_alarm) > 0
}
