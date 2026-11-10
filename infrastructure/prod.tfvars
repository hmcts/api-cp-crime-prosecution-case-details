api_mgmt_rg   = "rg-sps-platform-prod"
api_mgmt_name = "sps-api-mgmt-prod"

apim_product = {
  name                          = "cp-crime-prosecution-case-details"
  subscription_required         = true
  subscriptions_limit           = 20
  approval_required             = false
  published                     = true
  product_access_control_groups = ["developers", "administrators", "guests"]
}

entra_tenant_id = "0d0315f6-3c04-4edb-ac37-b05f580cc122"
entra_client_id = "fb911429-1f76-4bbe-8d80-7280a4b7ca4f"

apis = {
  prosecutioncasedetails = {
    openapi_spec_path = "../src/main/resources/openapi/openapi-spec.yml"
    display_name      = "Crime Prosecution Case Details API (pcd)"
    path              = "amp/pcd"
    service_host      = "prdamp01-appgw.prd.lv.cjscp"
    service_path      = "/pcd"
    revision          = "1"
  }
}
