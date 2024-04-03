# Infraestructura como Código

## Proyecto
El proyecto consiste en la implementación de una infraestructura en la nube utilizando los servicios de Amazon Web Services (AWS) y gestionándolos como código utilizando Terraform. El objetivo principal es crear una infraestructura escalable, segura y eficiente para alojar aplicaciones y datos.

## Servicios
- VPC (Virtual Private Cloud): Se creará una VPC en la región US-east-1 de AWS. Se le asignará un rango de CIDR de 10.0.0.0/16.
- Subnets:
  1. Subred Pública:
     - Se configurará una subred pública dentro de la VPC.
     - Esta subred estará asociada a una tabla de ruteo que incluirá una ruta hacia el Internet Gateway, permitiendo el acceso a Internet desde los recursos desplegados en esta subred.
     - Su rango de CIDR será 10.0.1.0/24.
  2. Subred Privada:
     - Se configurará una subred privada dentro de la VPC.
     - Esta subred estará aislada de Internet y no tendrá una ruta directa al Internet Gateway.
     - Su rango de CIDR será 10.0.0.0/24.
     - Los recursos desplegados en esta subred no tendrán direcciones IP públicas y estarán protegidos del acceso no autorizado desde Internet.
- Internet Gateway: Se configurará un Internet Gateway para permitir la comunicación bidreccional entre la infraestructura en la nube y la Internet pública.
- Tabla de Ruteo: Se creará una tabla de ruteo para dirigir el tráfico entre subredes privadas y públicas, asi como reglas para el acceso a Internet a través del Internet Gateway.
- EC2 Instances: Se crearán dos instancias EC2 para alojar las aplicaciones o servicios deseados.
- Amazon RDS Instances: Se configurarán dos instancias de Amazon RDS (Relational Database Service) para gestionar bases de datos relacionales.
- S3 Buckets: Se crearán dos buckets S3 para almacenar objetos como archivos estáticos, imágenes, archivos de configuración.

### Diagrama de Arquitectura

![diagrama](aws-arquitectura.png)

## Entorno de desarrollo

- Visual Studio Code(VSCODE): Editor de código Fuente
- AWS Command Line Interface(CLI): Se configurarán las credenciales necesarias para que terraform pueda acceder a la cuenta de AWS para la creación de infraestructura.
- Terrraform: Lenguaje de configuración para crear infraestructura como código en este caso en AWS.

## Desarrollo


Paso 1: Configuración del proveedor AWS

Script:

```
provider "aws" {
    region = "us-east-1"
}
```

Descripción de parámetros:

- `provider "aws"`: Esto indica que todos los recursos que se creen en este archivo pertenecerán a `AWS`.

- `region = "us-east-1"`: Esta línea especifica la región de `AWS` en la que se crearán los recursos. 

Paso 2: Creación de una VPC(Virtual Private Cloud) en AWS.

Script:

```
resource "aws_vpc" "istea_vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"

    tags = {
        Name = "MiVPC"
    }
}
```
Descripción de parámetros:

- `resource "aws_vpc" "istea_vpc"`: Definimos el recurso de tipo VPC en aws seguido del nombre `istea_vpc` como identificador único para este recurso.

- `cidr_block = "10.0.0/16"`: Se especifica el rango de direcciones IP que se asignará a la VPC.

- `instance_tenancy = "default"`:

- `tags = { Name = "MiVPC" }`: Nombre de etiqueta para el recurso de VPC.


Paso 3: Creación de una subred pública en AWS.

Script:

```
resource "aws_subnet" "publica" {
    vpc_id = aws_vpc.istea_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "RedPublica"
    }
}
```
Creando recurso Bucket S3 en aws

```
resource "aws_s3_bucket" "bucket_publico" {
  bucket = "bucket-publico-${aws_vpc.istea_vpc.cidr_block]"
  acl    = "private" 
}
```

```
resource "aws_s3_bucket_policy" "bucket_policy_privado" {
  bucket = aws_s3_bucket.bucket_privado.bucket

policy = jsonencode({
  Version = "2012-10-17",
  Statment = [
    {
      Effect  = "Allow",
      Principal = "*",
      Action = "s3:*",
      Resource = [aws_s3_bucket,bucket_privado.arn, aws_s3_bucket.bucket_publico.arn]
      Condition = {
        StringEquals = {
          "aws:SourceVpc" = aws_vpc.istea_vpc.id
        }
      }
    }
```
