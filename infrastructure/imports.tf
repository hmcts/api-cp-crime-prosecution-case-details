# Creating an APIM product auto-associates the built-in administrators group, so
# Terraform cannot create that association itself — it must be imported. The
# developers and guests associations are created by Terraform as normal.

locals {
  administrators_product_group_ids = {
    "sps-api-mgmt-sbox" = "/subscriptions/bd2864ed-4f3e-45ed-9c6a-8d179674bab1/resourceGroups/rg-sps-platform-sbox/providers/Microsoft.ApiManagement/service/sps-api-mgmt-sbox/products/cp-crime-prosecution-case-details/groups/administrators"
    "sps-api-mgmt-demo" = "/subscriptions/058bf954-ac1f-462b-bca4-42a30314bd74/resourceGroups/rg-sps-platform-demo/providers/Microsoft.ApiManagement/service/sps-api-mgmt-demo/products/cp-crime-prosecution-case-details/groups/administrators"
  }
}

import {
  for_each = contains(keys(local.administrators_product_group_ids), var.api_mgmt_name) ? toset(["administrators"]) : toset([])
  to       = module.product.azurerm_api_management_product_group.access_control_groups[each.value]
  id       = local.administrators_product_group_ids[var.api_mgmt_name]
}
