terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ----- APUNTAR A LOCALSTACK -----
provider "aws" {
  region = "us-east-1" # Región de emulación
  
  # Estas líneas le dicen a Terraform que hable
  # con tu "AWS Falso" (LocalStack) en localhost
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
# Definimos un "Security Group"
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

# ----- CREAR EL SERVIDOR (LA VM) -----
# Definimos una instancia "EC2"
resource "aws_instance" "mi_servidor_web" {
  # Usamos un ID de AMI 'genérico' para LocalStack
  ami           = "ami-12345678" 
  instance_type = "t2.micro"
  
  # Asociamos el firewall que creamos arriba
  security_groups = [aws_security_group.mi_firewall.name]

  tags = {
    Name = "Mi-Servidor-LocalStack"
  }
}

# ----- 4. IMPRIMIR EL "ID" -----
# Al final, le pedimos a Terraform que nos muestre
# el ID de la máquina que creó
output "id_servidor_local" {
  value = aws_instance.mi_servidor_web.id
}
