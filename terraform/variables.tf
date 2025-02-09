variable "compartment_id" {
  description = "OCID del compartment donde se desplegará la infraestructura"
  type        = string
}

variable "region" {
  description = "Región de OCI"
  type        = string
  default     = "eu-madrid-1"
}

variable "image_id" {
  description = "OCID de la imagen Oracle Linux"
  type        = string
  # Oracle Linux 8 ARM
  default     = "ocid1.image.oc1.eu-madrid-1.aaaaaaaawxpdqjiexlcsuhs3mbxdwuqmqwbzv2pxvlwgz2wbsjseeag6lgca"
} 