terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  
  endpoints {
    ec2 = "http://localhost:4566"
    s3  = "http://localhost:4566"
    iam = "http://localhost:4566"
  }
  
  # Estas líneas son para saltar chequeos que fallarían
  # en el emulador (no es el AWS real)
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# ----- FIREWALL -----
resource "aws_security_group" "mi_firewall" {
  name        = "mi-firewall"
  description = "Permite SSH y HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mi_servidor_web" {
  # ID de AMI 'genérico' para LocalStack
  ami           = "ami-12345678" 
  instance_type = "t2.micro"
  
  security_groups = [aws_security_group.mi_firewall.name]

  tags = {
    Name = "Mi-Servidor-LocalStack"
  }
}

output "id_servidor_local" {
  value = aws_instance.mi_servidor_web.id
}
