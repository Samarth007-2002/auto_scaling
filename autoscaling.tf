resource "aws_launch_template" "my_launch_template" {
    name_prefix = "my_launch_template_"
    image_id = "ami-0866a3c8686eaeeba" 
    instance_type = "t3.micro"
    key_name = "TF_key"
    vpc_security_group_ids = [ aws_security_group.ec2_sg.id ]
    user_data = filebase64("user_data.sh")
}

# Generate an RSA private key
resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits = 4096
}

# Define an AWS key pair resource named "TF_key".
# It creates an SSH key pair where the public key is derived
# from the RSA private key generated in the previous block.
# This key pair can be used to authenticate with EC2 instances launched in AWS.
resource "aws_key_pair" "TF_key" {
    key_name = "TF_key"
    public_key = tls_private_key.rsa.public_key_openssh
}

# Defines a local file resource named "private_key".
# It writes the content of the RSA private key generated in
# the first block to a file named "tfkey" on the local filesystem.
resource "local_file" "private_key" {
    content = tls_private_key.rsa.private_key_pem
    filename = "tfkey"
}

resource "aws_autoscaling_group" "my_asg" {
    vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]
    
    # Minimum number of instances the Auto Scaling group should maintain. 
    min_size = 1

    # Maximum number of instances the Auto Scaling group can scale up to
    max_size = 2

    # Specifies the desired number of instances that the Auto Scaling group
    # should maintain. It is set to 1, which means the Auto Scaling group will
    # initially launch and maintain one instance.
    desired_capacity = 1

    # Associate with ALB target group
    target_group_arns = [aws_lb_target_group.my_target_group.arn]

    tag {
        key = "Name"
        value = "My ASG"
        propagate_at_launch = true
    }

    # Specify the launch template defined before
    launch_template {
        id = aws_launch_template.my_launch_template.id
        version = "$Latest"
    }
}

resource "aws_autoscaling_policy" "increase_ec2" {
    name                   = "increase-ec2"
    scaling_adjustment     = 1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
    autoscaling_group_name = aws_autoscaling_group.my_asg.name
    policy_type = "SimpleScaling"
    
}

resource "aws_autoscaling_policy" "reduce_ec2" {
    name                   = "reduce-ec2"
    scaling_adjustment     = -1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
    autoscaling_group_name = aws_autoscaling_group.my_asg.name
    policy_type = "SimpleScaling"
}

# Attach the Auto Scaling Group to the ALB target group
resource "aws_autoscaling_attachment" "my_asg_attachment" {
    autoscaling_group_name = aws_autoscaling_group.my_asg.id
    lb_target_group_arn = aws_lb_target_group.my_target_group.arn
}
