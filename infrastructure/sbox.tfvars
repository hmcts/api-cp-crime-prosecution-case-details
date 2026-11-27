api_mgmt_rg   = "rg-sps-platform-sbox"
api_mgmt_name = "sps-api-mgmt-sbox"

apim_product = {
  name                          = "cp-crime-prosecution-case-details"
  subscription_required         = true
  subscriptions_limit           = 20
  approval_required             = false
  published                     = true
  product_access_control_groups = ["developers", "administrators", "guests"]
}

entra_tenant_id = "d44f885c-4fac-47bf-afde-d7d861ec4d7b"
entra_client_id = "9dbae12a-8cba-4965-9940-62d10a5e3183"

apis = {
  prosecutioncasedetails = {
    openapi_spec_path = "../src/main/resources/openapi/openapi-spec.yml"
    display_name      = "Crime Prosecution Case Details API (pcd)"
    path              = "amp/pcd"
    service_host      = "ccp-marketplace.dev.nl.cjscp"
    service_path      = "/pcd"
    revision          = "1"
  }
}

# APIM swaps the consumer's token for a CP token, so the backend (on the oauth gateway) accepts it.
cp_token_exchange = {
  tenant_id               = "e2995d11-9947-4e78-9de6-d44e0603518e" # CP nonlive (mdv)
  audience                = "54de515d-d49d-469f-9a1c-e0c801b283fd" # spn_amp_api_pcd_publisher (mdv)
  identity_name           = "sps-api-mgmt-token-exchange-sbox"
  identity_resource_group = "rg-sps-platform-sbox"
  # "<external consumer client ID>" = "<CP-access app client ID>"
  client_map = {
    "378a2954-c99b-4f8d-a35b-e0e70ecd3ea5" = "6e2b811a-29f0-40a3-9af8-2ad42c62d0cd" # amp-test-external-client => amp-cpaccess-consumer-poc-sbox
  }
  # Unmapped consumers are forwarded unchanged, as on SLC.
  reject_unmapped = false
}
