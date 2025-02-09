# Internet Gateway
resource "oci_core_internet_gateway" "n8n_ollama_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.n8n_ollama_vcn.id
  display_name   = "n8n-ollama-igw"
}

# Route Table
resource "oci_core_route_table" "n8n_ollama_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.n8n_ollama_vcn.id
  display_name   = "n8n-ollama-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.n8n_ollama_igw.id
  }
}

# Security List
resource "oci_core_security_list" "n8n_ollama_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.n8n_ollama_vcn.id
  display_name   = "n8n-ollama-sl"

  # Permitir SSH
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Permitir HTTP/HTTPS
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # Permitir todo el tráfico saliente
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
} 