# In the code below, you are defining the provider as aws.
provider "aws" {
    region     = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}


# Next, we want to tell Terraform to create an Elastic Beanstalk application
resource "aws_elastic_beanstalk_application" "whizapp"{
    name        = "test"
    description = "Sample Test Application"
}

# Let’s add another set of code after the elastic beanstalk application creation. Paste the following code in the main.tf file. This code will create an instance profile for the EC2 Instance. The code includes the creation of an IAM role, and attaching the required IAM policies to the role.

resource "aws_iam_instance_profile" "subject_profile" {
  name = "test_role_new"
  role = aws_iam_role.role.name
}
resource "aws_iam_role" "role" {
  name = "test_role_new"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier", 
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier",
  ])

  role = "${aws_iam_role.role.name}"
  policy_arn = each.value
}



# create an elastic environment for the application, paste the below code in the main.tf
resource "aws_elastic_beanstalk_environment" "whizenv" {
  name = "whizenvironment"
  application = aws_elastic_beanstalk_application.whizapp.name
  solution_stack_name = "64bit Amazon Linux 2023 v5.6.2 running Tomcat 11 Corretto 17"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = aws_iam_instance_profile.subject_profile.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name = "MatcherHTTPCode"
    value = "200"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "LoadBalancerType"
    value = "application"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.micro"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = 1
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name = "MaxSize"
    value = 2
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name = "SystemType"
    value = "enhanced"
  }
}
# In the above code, we have declared the resource type as aws_elastic_beanstalk_environment for the environment of the Elastic Beanstalk application. 

# a. solution_stack_name is the name of an environment that Elastic Beanstalk will set up on servers it manages. The solution stack here is 64bit Amazon Linux 2 v3.4.1 running Corretto 17 for Java.

# b. There are other additional settings added for the environment that are required for the environment to launch like Autoscaling Launch configuration, Load balancer, and the minimum and maximum size for the autoscaling group. 