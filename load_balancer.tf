resource "aws_lb" "my_application_load_balancer" {
    name               = "my-application-load-balancer"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb_sg.id]
    subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]
    enable_cross_zone_load_balancing = true
    enable_deletion_protection = false
    tags = {
        Name = "My application load balancer"
    }
    depends_on = [ aws_internet_gateway.my_igw ]
}

resource "aws_lb_target_group" "my_target_group" {
    name     = "my-target-group"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.my_new_vpc.id
    target_type = "instance"
    health_check {
        path                = "/"
        protocol            = "HTTP"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 4
        interval            = 5
    }
    tags = {
        Name = "My target group"
    }
}


resource "aws_lb_listener" "my_listener" {
    load_balancer_arn = aws_lb.my_application_load_balancer.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.my_target_group.arn
    }
}
