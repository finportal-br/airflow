variable "location" {
  default = "eastus"
}

variable "ssh_public_key" {
  description = "Chave pública SSH para acesso à VM"
  type        = string
}
