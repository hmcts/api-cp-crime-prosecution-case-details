api_mgmt_rg   = "rg-sps-platform-demo"
api_mgmt_name = "sps-api-mgmt-demo"

apim_product = {
  name                          = "cp-crime-prosecution-case-details"
  subscription_required         = true
  subscriptions_limit           = 20
  approval_required             = false
  published                     = true
  product_access_control_groups = ["developers", "administrators", "guests"]
}

entra_tenant_id = "db827888-77df-4707-b3d9-24a3dfe32889"
entra_client_id = "2503b36a-f7b6-493f-9957-402e9d02971a"

apis = {
  prosecutioncasedetails = {
    openapi_spec_path = "../src/main/resources/openapi/openapi-spec.yml"
    display_name      = "Crime Prosecution Case Details API (pcd)"
    path              = "amp/pcd"
    service_host      = "sitamp01-appgw.sit.nl.cjscp"
    service_path      = "/pcd"
    revision          = "1"
  }
}
