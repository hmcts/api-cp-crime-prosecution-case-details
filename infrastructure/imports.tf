# Creating an APIM product auto-associates the built-in administrators group, so
# Terraform cannot create that association itself — it must be imported. The
# developers and guests associations are created by Terraform as normal.

locals {
  apim_base = "/subscriptions/bd2864ed-4f3e-45ed-9c6a-8d179674bab1/resourceGroups/rg-sps-platform-sbox/providers/Microsoft.ApiManagement/service/sps-api-mgmt-sbox"
}

import {
  to = module.product.azurerm_api_management_product_group.access_control_groups["administrators"]
  id = "${local.apim_base}/products/cp-crime-prosecution-case-details/groups/administrators"
}
