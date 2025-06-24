# In the code below, we will extract the arn of the elastic beanstalk application.
output "aws_beanstalk_app" {
  value = aws_elastic_beanstalk_application.whizapp.arn
}
