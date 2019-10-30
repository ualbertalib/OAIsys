# TODO: Extending off base rather than api because render wouldn't find views, look into another way to resolve this.
class Oaisys::ApplicationController < ActionController::Base

  # protect_from_forgery with: :exception
  rescue_from 'Oaisys::PMHError' do |exception|
    respond_to do |format|
      format.xml do
        render :error, locals: {
          verb: exception.for_verb, error_code: exception.error_code, error_message: exception.error_message
        }
      end
    end
  end

end
