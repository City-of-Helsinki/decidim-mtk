# frozen_string_literal: true

class ConfirmationsController < ::Decidim::Devise::ConfirmationsController
  protected
    def after_confirmation_path_for(resource_name, resource)
      session[:open_user_form] = true
      super
    end
end
