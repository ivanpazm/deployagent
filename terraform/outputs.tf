output "instance_ip" {
  description = "IP pública de la instancia"
  value       = google_compute_instance.n8n_ollama.network_interface[0].access_config[0].nat_ip
}

output "instance_name" {
  description = "Nombre de la instancia"
  value       = google_compute_instance.n8n_ollama.name
}

output "instance_id" {
  description = "OCID de la instancia"
  value       = oci_core_instance.n8n_ollama_instance.id
}

output "vcn_id" {
  description = "OCID de la VCN"
  value       = oci_core_vcn.n8n_ollama_vcn.id
} 