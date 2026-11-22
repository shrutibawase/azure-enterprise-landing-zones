# Enterprise Web Application Firewall (WAF) Policy
resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = "wafp-${var.app_gateway_name}"
  resource_group_name = var.resource_group_name
  location            = var.location

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }

    managed_rule_set {
      type    = "Microsoft_BotManagerRuleSet"
      version = "1.0"
    }
  }

  custom_rules {
    name      = "RateLimitPerClientIP"
    priority  = 1
    rule_type = "RateLimitRule"
    action    = "Block"

    rate_limit_duration    = "OneMin"
    rate_limit_threshold   = 100

    match_conditions {
      match_variables {
        variable_name = "RequestUri"
      }
      operator           = "BeginsWith"
      negation_condition = false
      match_values       = ["/api/"]
    }
  }

  tags = var.tags
}
