variable "prefix" {
  default = "bobby"
}

variable "purpose" {
  default = "project"
}

variable "location" {
  default = "eastus"
}

variable "image" {
  default = "/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Compute/images/BobbyPackerImage"
}

variable "numVms" {
  default = 2
}