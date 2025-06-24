# In the code below, you are defining the provider as aws.
provider "aws" {
    region     = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}			



# To create a security group Paste the below content into the main.tf file after the provider
############ Creating Security Group for EC2 ############
resource "aws_security_group" "web-server" {
    name        = "web-server"
    description = "Allow incoming HTTP Connections"
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}			


# Create a Key pair in main.tf file
############ Creating Key pair for EC2 ############
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "whiz_key" {
  key_name   = "WhizKey"
  public_key = tls_private_key.example.public_key_openssh
}			


# Launch an EC2 Instance in main.tf file
################## Launching EC2 Instance ##################
resource "aws_instance" "web-server" {
    ami             = "ami-01cc34ab2709337aa"
    instance_type   = "t2.micro"
    key_name        = aws_key_pair.whiz_key.key_name
    security_groups = ["${aws_security_group.web-server.name}"]
    tags = {
        Name = "MyEC2Server"
    }
}			



# Create SNS Topic in main.tf file
############ Creating an SNS Topic ############
resource "aws_sns_topic" "topic" {
  name = "MyServerMonitor"
}			



# Create SNS Topic Subscription in main.tf file
############ Creating SNS Topic Subscription ############
resource "aws_sns_topic_subscription" "topic-subscription" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint= var.endpoint
}			


#Create a CloudWatch Event in main.tf file
############ Creating CloudWatch Event ############
resource "aws_cloudwatch_event_rule" "event" {
  name        = "MyEC2StateChangeEvent"
  description = "MyEC2StateChangeEvent"
  event_pattern = <<EOF
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ]
}
EOF
}
resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.event.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.topic.arn
}
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}
data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    resources = [aws_sns_topic.topic.arn]
  }
}			
# In above code we are creating a CloudWatch event rule that triggers when an Amazon Elastic Compute Cloud (Amazon EC2) instance changes state. When the event is triggered, it sends a notification to an Amazon Simple Notification Service (SNS) topic. The SNS topic is also given permission to publish messages by an Amazon Identity and Access Management (IAM) policy.