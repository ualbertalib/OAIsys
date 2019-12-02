module Oaisys
  require 'oaisys/engine'
  require 'oaisys/pmh_error'
  require 'oaisys/bad_argument_error'
  require 'oaisys/cannot_disseminate_format_error'
  require 'oaisys/no_records_match_error'

  # Set an action on unpermitted parameters to raise an exception, used to validate parameters.
  ActionController::Parameters.action_on_unpermitted_parameters = :raise
end
