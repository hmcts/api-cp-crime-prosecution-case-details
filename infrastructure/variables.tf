# ─── Variables injected automatically by the HMCTS GitHub Actions reusable workflow ───

variable "env" {
  type        = string
  description = "Environment name, injected by CI (e.g. sbox, dev, prod)."
  default     = ""
}

variable "product" {
  type        = string
  description = "Product name, injected by CI."
  default     = ""
}

variable "subscription" {
  type        = string
  description = "Azure subscription ID, injected by CI."
  default     = ""
}

variable "aks_subscription_id" {
  type        = string
  description = "AKS subscription ID, injected by CI."
  default     = ""
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID, injected by CI."
  default     = ""
}

variable "builtFrom" {
  type        = string
  description = "Repository reference, injected by CI."
  default     = ""
}

variable "ci_service_principal_object_id" {
  type        = string
  description = "CI service principal object ID, injected by CI."
  default     = ""
}

# ─── Module-specific variables ───

variable "api_mgmt_rg" {
  type        = string
  description = "Resource group name of the target APIM instance."
}

variable "api_mgmt_name" {
  type        = string
  description = "Name of the target APIM instance."
}

variable "apim_product" {
  description = "Product configuration to create in APIM."
  type = object({
    name                          = string
    subscription_required         = optional(bool, true)
    subscriptions_limit           = optional(number, 20)
    approval_required             = optional(bool, true)
    published                     = optional(bool, true)
    product_access_control_groups = optional(list(string), [])
  })
}

variable "entra_tenant_id" {
  type        = string
  description = "Entra tenant ID used in the product JWT validation policy."
}

variable "entra_client_id" {
  type        = string
  description = "Entra client ID (audience) used in the product JWT validation policy."
}

variable "apis" {
  description = "Map of APIs to register in APIM. Details are sourced from the referenced OpenAPI spec file."
  type = map(object({
    openapi_spec_path     = string
    service_host          = string
    service_path          = optional(string, "")
    name                  = optional(string)
    display_name          = optional(string)
    path                  = optional(string)
    revision              = optional(string, "1")
    protocols             = optional(list(string), ["https"])
    subscription_required = optional(bool, true)
    api_type              = optional(string, "http")
  }))
}

variable "cp_token_exchange" {
  description = <<-EOT
    When set, APIM swaps the validated external token for a CP-issued token before calling the backend.
    APIM signs in to the CP tenant as the consumer's CP-access app, using its user-assigned managed identity
    as a federated credential (no secret), and caches the CP token per CP-access app.
  EOT
  type = object({
    # CP tenant that issues the token.
    tenant_id = string
    # Client ID of the CP API's publisher app; the token is requested for "<audience>/.default".
    audience = string
    # APIM's user-assigned identity that the CP-access apps' federated credentials trust.
    identity_name           = string
    identity_resource_group = string
    # External consumer client ID (the token's azp) => that consumer's CP-access app client ID.
    client_map = optional(map(string), {})
    # true: a consumer missing from client_map gets 403. false: its request is forwarded unchanged,
    # with the external token, so existing consumers keep working while the swap is introduced.
    reject_unmapped = optional(bool, true)
    # The CP token is cached until this many seconds before it expires.
    cache_buffer_seconds = optional(number, 300)
  })
  default = null

  validation {
    condition = var.cp_token_exchange == null || alltrue(concat(
      [for id in [try(var.cp_token_exchange.tenant_id, ""), try(var.cp_token_exchange.audience, "")] : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", id))],
      [for k, v in try(var.cp_token_exchange.client_map, {}) : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", k)) && can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", v))]
    ))
    error_message = "cp_token_exchange tenant_id, audience and every client_map key and value must be lower-case GUIDs."
  }
}
