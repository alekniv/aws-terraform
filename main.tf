provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "istea_vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"

    tags = {
        Name = "MiVPC"
    }
}

resource "aws_subnet" "publica" {
    vpc_id = aws_vpc.istea_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "RedPublica"
    }
}

resource "aws_subnet" "privada" {
    vpc_id = aws_vpc.istea_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"

    tags = {
        Name = "RedPrivada"
    }
}

resource "aws_internet_gateway" "istea_igw" {
    vpc_id = aws_vpc.istea_vpc.id
}


resource "aws_nat_gateway" "istea_nat_gateway" {
    allocation_id = aws_eip.istea_eip.id
    subnet_id = aws_subnet.privada.id
}

resource "aws_eip" "istea_eip" {
    domain = "vpc"
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.istea_vpc.id

  tags = {
    Name = "Tabla de enrutamiento pública"
  }
}

resource "aws_route" "acceso_internet" {
    route_table_id = aws_route_table.publica.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.istea_igw.id
}

# Definir una instancia EC2 en la Subnet1
resource "aws_instance" "instance_publica" {
  ami = "ami-080e1f13689e07408" # AMI de la instancia
  instance_type = "t2.micro" # Tipo de instancia
  key_name = "istea_key" # Nombre de la llave SSH
  
  subnet_id = aws_subnet.publica.id # Asociar la instancia con la subnet1

  tags = {
    Name = "Instancia_Publica"
  } 
}

# Definir una instancia EC2 en la subnet2
resource "aws_instance" "instance_privada" {
    ami = "ami-080e1f13689e07408" # AMI de la instancia
    instance_type = "t2.micro" # Tipo de instancia
    subnet_id = aws_subnet.privada.id # Asociar la instancia con la subnet2

    tags = {
      Name = "Instancia Privada"
    }
}

resource "aws_s3_bucket" "bucket_publico" {
  bucket = "bucket-publico-${aws_vpc.istea_vpc.id}"
}

resource "aws_s3_bucket" "bucket_privado" {
  bucket = "bucket-privado-${aws_vpc.istea_vpc.id}"
}

resource "aws_s3_bucket_policy" "bucket_policy_publico" {
  bucket = aws_s3_bucket.bucket_publico.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket_publico.arn}/*",
        Condition = {
          StringEquals = {
            "aws:SourceVpc" = "${aws_vpc.istea_vpc.id}"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "bucket_policy_privado" {
  bucket = aws_s3_bucket.bucket_privado.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket_privado.arn}/*",
        Condition = {
          StringEquals = {
            "aws:SourceVpc" = "${aws_vpc.istea_vpc.id}"
          }
        }
      }
    ]
  })
}
