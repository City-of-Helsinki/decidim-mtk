# Include this in Decidim::AttachmentForm
module UserNicknamer
  extend ActiveSupport::Concern
  include UserUtility

  included do
    before_action :set_nickname, only: [:create, :update]
  end

  private
    def set_nickname
      if user_params = params[:user]
        # Don't update the username in case name does not change
        if current_user && params[:user][:name] == current_user.name
          return
        end

        params[:user][:nickname] = generate_nickname(
          user_params[:email],
          user_params[:name]
        )
      end
    end
end
