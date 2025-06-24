# Create a security group for RDS and EC2 in main.tf file

provider "aws" {
    region     = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}


#Creating a security group    
resource "aws_security_group" "rds_sg" {      
  name = "rds_sg"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
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


# Adding RDS Instance in the main.tf file

#Creating RDS Database Instance
# In the code below, we have declared the engine as mysql, instance class as db.t3.micro, setting username as whizuser, and password as whizpassword. To skip creating the final snapshot while deleting the RDS instance, we have added skip_final_snapshot as true. This password will be helpful when connecting to mysql through EC2 Instance.
resource "aws_db_instance" "myinstance" {
  engine               = "mysql"
  identifier           = "mydatabaseinstance"
  allocated_storage    =  20
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "whizuser"
  password             = "whizpassword"
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  skip_final_snapshot  = true
  publicly_accessible =  true   
}


# Add EC2 Instance creation in the main.tf file
# In the code below, we have declared the ami id used for the web-server, instance type and the security group that will be used for the EC2 Instance. Also the user data has been added to update and install the mysql beforehand. 

resource "aws_instance" "web-server" {
    ami = "ami-02e136e904f3da870"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.rds_sg.name}"]
    user_data = <<-EOF
    #!/bin/bash
    sudo su
    yum update -y
    yum install mysql -y
    EOF
    tags = {
        Name = "whiz_instance"  
    }     
}
