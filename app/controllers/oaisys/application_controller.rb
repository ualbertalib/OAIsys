module Oaisys
  # TODO: Extending off base rather than api because render wouldn't find views, look into another way to resolve this.
  class ApplicationController < ActionController::Base
    # protect_from_forgery with: :exception
  end
end
