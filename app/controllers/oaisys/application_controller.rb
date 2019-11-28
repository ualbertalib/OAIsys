# TODO: Extending off base rather than api because render wouldn't find views, look into another way to resolve this.
class Oaisys::ApplicationController < ActionController::Base

  rescue_from 'ActionController::UnpermittedParameters', 'ActionController::ParameterMissing' do
    respond_to do |format|
      format.xml do
        render :error, locals: {
          parameters: params.to_unsafe_h.slice(:verb), error_code: :badArgument,
          error_message: I18n.t('error_messages.illegal_or_missing_arguments')
        }
      end
    end
  end

  # protect_from_forgery with: :exception
  rescue_from 'Oaisys::PMHError' do |exception|
    respond_to do |format|
      format.xml do
        render :error, locals: {
          parameters: exception.parameters, error_code: exception.error_code, error_message: exception.error_message
        }
      end
    end
  end

end
