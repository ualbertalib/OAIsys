class Oaisys::Engine < ::Rails::Engine

  isolate_namespace Oaisys
  config.generators.api_only = true
  config.items_per_request = 150

end
