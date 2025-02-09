terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "~> 4.0"
    }
  }
}

provider "oci" {
  region = var.region
}

# VCN
resource "oci_core_vcn" "n8n_ollama_vcn" {
  compartment_id = var.compartment_id
  cidr_block     = "10.0.0.0/16"
  display_name   = "n8n-ollama-vcn"
}

# Subnet
resource "oci_core_subnet" "n8n_ollama_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.n8n_ollama_vcn.id
  cidr_block     = "10.0.1.0/24"
  display_name   = "n8n-ollama-subnet"
}

# Compute Instance
resource "oci_core_instance" "n8n_ollama_instance" {
  compartment_id = var.compartment_id
  shape         = "VM.Standard.A1.Flex"
  display_name  = "n8n-ollama"

  shape_config {
    ocpus = 4
    memory_in_gbs = 24
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.n8n_ollama_subnet.id
  }
} 