output "instance_ip" {
  description = "IP pública de la instancia"
  value       = oci_core_instance.n8n_ollama_instance.public_ip
}

output "instance_id" {
  description = "OCID de la instancia"
  value       = oci_core_instance.n8n_ollama_instance.id
}

output "vcn_id" {
  description = "OCID de la VCN"
  value       = oci_core_vcn.n8n_ollama_vcn.id
} 