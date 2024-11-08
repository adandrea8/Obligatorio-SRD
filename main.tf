provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc_obligatorio" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc_obligatorio"
  }
}

resource "aws_security_group" "sg_siem" {
  vpc_id = aws_vpc.vpc_obligatorio.id
  name   = "sg_siem"

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

  tags = {
    Name = "sg_siem"
  }
}


resource "aws_instance" "siem" {
  ami           = "ami-064519b8c76274859"  
  instance_type = "t2.micro"               
  subnet_id     = aws_subnet.subnet_private_a.id
  security_groups = [aws_security_group.sg_jump_server.id]  
 
  key_name = "vockey" 

  tags = {
    Name = "siem"
  }
}

resource "aws_security_group" "sg_jump_server" {
  vpc_id = aws_vpc.vpc_obligatorio.id
  name   = "sg_jump_server"

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

  tags = {
    Name = "sg_jump_server"
  }
}


resource "aws_instance" "jump_server" {
  ami           = "ami-064519b8c76274859"  
  instance_type = "t2.micro"               
  subnet_id     = aws_subnet.subnet_public_a.id
  security_groups = [aws_security_group.sg_jump_server.id]  
 
  key_name = "vockey" 

  tags = {
    Name = "jump_server"
  }
}

resource "aws_security_group" "sg_load_balancer" {
  name = "sg_load_balancer"
  vpc_id = aws_vpc.vpc_obligatorio.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # ingresar ip del WAF
  }
  tags = {
    Name = "sg_load_balancer"
  }
}

resource "aws_security_group" "sg_appweb" {
  name = "sg_appweb"
  vpc_id = aws_vpc.vpc_obligatorio.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ingresar ip del servidor de administracion
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups  = [aws_security_group.sg_load_balancer.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # luego de la instalacion se debe quitar la salida a internet (se podria hacer creando un security group con un deny que se aplique luego de que este todo hecho con un depends on)
  }
  tags = {
    Name = "sg_appweb"
  }
}

# resource "aws_security_group" "tf_sg_mysql_obligatorio" {
#   name        = "tf_sg_mysql_obligatorio"
#   description = "Security group MySQL"
#   vpc_id      = aws_vpc.vpc_obligatorio.id

#   ingress {
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     security_groups  = [aws_security_group.sg_appweb.id]
#   }
# }


# Crear un Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc_obligatorio.id
  tags = {
    Name = "internet_gateway"
  }
}

# Crear subredes privadas y publicas en las zonas de disponibilidad A y B dentro de la nueva VPC
resource "aws_subnet" "subnet_private_a" {
  vpc_id            = aws_vpc.vpc_obligatorio.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "subnet_private_a"
  }
}

resource "aws_subnet" "subnet_private_b" {
  vpc_id            = aws_vpc.vpc_obligatorio.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "subnet_private_b"
  }
}

resource "aws_subnet" "subnet_public_a" {
  vpc_id            = aws_vpc.vpc_obligatorio.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "subnet_public_a"
  }
}

resource "aws_subnet" "subnet_public_b" {
  vpc_id            = aws_vpc.vpc_obligatorio.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "subnet_public_a"
  }
}



# Crear grupo de subredes para la base de datos dentro de la nueva VPC
#resource "aws_db_subnet_group" "obligatorio_db_subnet_group" {
#  name       = "obligatorio-db-subnet-group"
#  subnet_ids = [aws_subnet.subnet_private_a.id, aws_subnet.subnet_private_b.id]
#}


resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc_obligatorio.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "route_table"
  }
}

resource "aws_route_table_association" "subnet_public_a_asso" {
  subnet_id      = aws_subnet.subnet_public_a.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet_public_b_asso" {
  subnet_id      = aws_subnet.subnet_public_b.id
  route_table_id = aws_route_table.route_table.id
}

# Crear una Elastic IP para el NAT Gateway de la AV a
resource "aws_eip" "nat_eip_a" {
  domain = "vpc"
}

# Crear el NAT Gateway en la subred pública de la AV a
resource "aws_nat_gateway" "nat_gateway_a" {
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.subnet_public_a.id

}

# Crear una tabla de rutas para la subred privada a
resource "aws_route_table" "private_route_table_a" {
  vpc_id = aws_vpc.vpc_obligatorio.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_a.id
  }

}

# Asociar la tabla de rutas privada a la subred privada a
resource "aws_route_table_association" "subnet_private_a_asso" {
  subnet_id      = aws_subnet.subnet_private_a.id
  route_table_id = aws_route_table.private_route_table_a.id
}


# Crear una Elastic IP para el NAT Gateway de la AV b
resource "aws_eip" "nat_eip_b" {
  domain = "vpc"
}

# Crear el NAT Gateway en la subred pública de la AV b
resource "aws_nat_gateway" "nat_gateway_b" {
  allocation_id = aws_eip.nat_eip_b.id
  subnet_id     = aws_subnet.subnet_public_b.id

}

# Crear una tabla de rutas para la subred privada b
resource "aws_route_table" "private_route_table_b" {
  vpc_id = aws_vpc.vpc_obligatorio.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_b.id
  }

}

# Asociar la tabla de rutas privada a la subred privada b
resource "aws_route_table_association" "subnet_private_b_asso" {
  subnet_id      = aws_subnet.subnet_private_b.id
  route_table_id = aws_route_table.private_route_table_b.id
}


# Crear un balanceador de carga de aplicación (ALB)
resource "aws_lb" "aplitation_load_balancer" {
  name               = "aplitation-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_load_balancer.id]
  subnets            = [aws_subnet.subnet_private_a.id, aws_subnet.subnet_private_b.id]


}

# Definir reglas de escucha y destino para el ALB
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.aplitation_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.obligatorio_target_group.arn
  }
}

# Crear grupos de destino para las instancias de aplicación en las zonas de disponibilidad A y B
resource "aws_lb_target_group" "obligatorio_target_group" {
  name        = "obligatorio-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc_obligatorio.id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 60
  }

}

resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.obligatorio_target_group.arn

  }
  condition {
    path_pattern {
      values = ["/var/www/html/index.html"]
    }
  }
}

# resource "aws_db_instance" "obligatorio-db" {
#   allocated_storage    = 20
#   storage_type         = "gp2"
#   engine               = "mysql"
#   engine_version       = "5.7.44" 
#   instance_class       = "db.t3.micro" 
#   username             = "admin"
#   password             = "password"
#   skip_final_snapshot  = true
#   vpc_security_group_ids = [aws_security_group.tf_sg_mysql_obligatorio.id]
#   db_subnet_group_name = aws_db_subnet_group.obligatorio_db_subnet_group.name
#   db_name              = "iDukan"
#   tags = {
#     Name = "obligatorio-db"
#   }
# }


#locals {
 # webapp_user_data = <<-EOF
   # #!/bin/bash
    
  
  #  sudo systemctl enable httpd
  #  sudo systemctl start httpd
    
    
    #sudo systemctl restart httpd
#  EOF
#}

resource "aws_launch_template" "webapp_launch_template" {
  name_prefix   = "webapp_launch_template"
  image_id      = "ami-064519b8c76274859"
  instance_type = "t2.micro"
  key_name      = "vockey"
  ebs_optimized = false  # Opcional: ajusta según tus necesidades

  #depends_on = [aws_db_instance.obligatorio-db, aws_efs_file_system.efs_obligatorio]

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.subnet_private_a.id
    security_groups             = [aws_security_group.sg_appweb.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name      = "webapp"
      terraform = "True"
    }
  }

  #user_data = base64encode(local.webapp_user_data)
}

resource "aws_autoscaling_group" "webapp_autoscaling_group" {
  name      = "webapp-autoscaling-group"
  launch_template {
    id      = aws_launch_template.webapp_launch_template.id
    version = "$Latest"
  }

  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2

  vpc_zone_identifier       = [aws_subnet.subnet_private_a.id, aws_subnet.subnet_private_b.id]  # ID de la subred donde lanzar las instancias

  target_group_arns         = [aws_lb_target_group.obligatorio_target_group.arn]  # ARN del Target Group si se usa con un ALB

  health_check_type         = "EC2"  # Cambiado a EC2
  health_check_grace_period = 300  # Aumentado a 300 segundos (5 minutos)

  lifecycle {
    create_before_destroy   = true
  }
  
  depends_on = [aws_launch_template.webapp_launch_template]
}
