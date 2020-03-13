class Oaisys::Engine < ::Rails::Engine

  isolate_namespace Oaisys
  config.generators.api_only = true
  config.items_per_request = 150
  config.resumption_token_expiry = 72.hours

end
