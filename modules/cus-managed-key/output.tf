# output "resource_group_name" {
#   description = "The name of the resource group in which resources are created"
#   value       = element(coalescelist(data.azurerm_resource_group.rgrp.*.name,  [""]), 0)
# }

