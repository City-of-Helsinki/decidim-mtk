# frozen_string_literal: true

module Devise
  class OmniauthRegistrationsController < ::Decidim::Devise::OmniauthRegistrationsController
    # Customize the user creation in order to customize the success message
    # and make it possible to show the form to manually fill the user details
    # (name).
    def create
      form_params = params[:user] || user_params_from_oauth_hash

      @form = form(Decidim::OmniauthRegistrationForm).from_params(form_params)
      @form.email ||= verified_email

      # Make sure the name check fails in case we just returned from the
      # omniauth authentication.
      unless params[:user]
        @form.name = nil
      end

      Decidim::CreateOmniauthRegistration.call(@form, verified_email) do
        on(:ok) do |user|
          session.delete(:oauth_hash)

          mark_tos_accepted user
          handle_tunnistamo_success user
        end

        on(:invalid) do
          set_flash_message :notice, :success, kind: provider_name(@form.provider)

          # Save the oauth_hash for futher requests
          session[:oauth_hash] ||= oauth_hash

          unless params[:user]
            # Preset the parameters for the view in case we just returned from
            # the omniauth authentication.
            @form.name = oauth_name
            @form.nickname = oauth_nickname
          end

          # Do not show errors regarding these fields on the form
          @form.errors.delete(:name)
          @form.errors.delete(:nickname)

          render :new
        end

        on(:error) do |user|
          if user.errors[:email]
            set_flash_message :alert, :failure, kind: provider_name(@form.provider), reason: t("decidim.devise.omniauth_registrations.create.email_already_exists")
          end

          redirect_to new_user_session_path
        end
      end
    end

    def tunnistamo
      # `true`  = Allow users to fill in registration details (name)
      # `false` = Automatically read the details from the omniauth passed data
      if true
        create
      else
        tunnistamo_direct
      end
    end

    # Customized tunnistamo callback to bypass setting up the user parameters
    # This is called after the user returns from the Omniauth flow. Otherwise
    # the user would be shown the omniauth registration form.
    def tunnistamo_direct
      info = oauth_data[:info] || {}

      # Fetch the nickname passed form Tunnistamo
      nickname = oauth_nickname

      identity = Decidim::Identity.find_by(uid: oauth_data[:uid])
      if identity
        user = identity.user
        if user
          # Update user if it already existed
          user.update(
            email: verified_email,
            # name: oauth_name,
          )

          set_flash_message :notice, :success, kind: provider_name(oauth_data[:provider])
          handle_tunnistamo_success user
          return
        else
          identity.destroy!
        end
      end

      @form = form(Decidim::OmniauthRegistrationForm).from_params({
        uid: oauth_data[:uid],
        provider: oauth_data[:provider],
        oauth_signature: Decidim::OmniauthRegistrationForm.create_signature(oauth_data[:provider], oauth_data[:uid]),
        email: info[:email],
        name: oauth_name,
        nickname: oauth_nickname,
      })

      Decidim::CreateOmniauthRegistration.call(@form, verified_email) do
        on(:ok) do |user|
          mark_tos_accepted user
          set_flash_message :notice, :success, kind: provider_name(@form.provider)
          handle_tunnistamo_success user
        end

        on(:invalid) do
          set_flash_message :notice, :success, kind: provider_name(@form.provider)
          redirect_to root_path
        end

        on(:error) do |user|
          if user.errors[:email]
            set_flash_message :alert, :failure, kind: provider_name(@form.provider), reason: t("decidim.devise.omniauth_registrations.create.email_already_exists")
          end

          redirect_to root_path
        end
      end
    end

    private
      def handle_tunnistamo_success(user)
        if user.active_for_authentication?
          sign_in_and_redirect user, event: :authentication
        else
          expire_data_after_sign_in!
          redirect_to root_path
          flash[:notice] = t("devise.registrations.signed_up_but_unconfirmed")
        end
      end

      def mark_tos_accepted(user)
        if user.accepted_tos_version.nil?
          user.update(
            accepted_tos_version: current_organization.tos_version,
          )
        end
      end

      def oauth_name
        oauth_data.dig(:info, :name) || oauth_nickname || verified_email.split('@').first
      end

      def oauth_nickname
        # Fetch the nickname passed form Tunnistamo
        oauth_data.dig(:info, :nickname) || oauth_hash.dig(:extra, :raw_info, :nickname)
      end

      def provider_name(provider)
        if provider.to_sym == :tunnistamo
          "Helsinki - Tunnistamo"
        else
          provider.capitalize
        end
      end

      def oauth_hash
        raw_hash = request.env["omniauth.auth"] || session[:oauth_hash]
        return {} unless raw_hash

        raw_hash.deep_symbolize_keys
      end
  end
end
