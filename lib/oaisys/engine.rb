module Oaisys
  class Engine < ::Rails::Engine
    isolate_namespace Oaisys
    config.generators.api_only = true
  end
end
