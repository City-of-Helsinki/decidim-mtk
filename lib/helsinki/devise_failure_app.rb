# frozen_string_literal: true

module Helsinki
  class DeviseFailureApp < Devise::FailureApp
    protected
      def i18n_message(default = nil)
        locale = if request_locale
          request_locale
        elsif current_user && current_user.locale.present?
          current_user.locale
        end

        I18n.with_locale(available_locales.include?(locale) ? locale : default_locale) { super }
      end

      # Fixes the following bug by passing the locale to the URL helper method:
      # https://github.com/decidim/decidim/issues/4660
      def scope_url
        opts  = {}

        # Initialize script_name with nil to prevent infinite loops in
        # authenticated mounted engines in rails 4.2 and 5.0
        opts[:script_name] = nil

        route = route(scope)

        opts[:format] = request_format unless skip_format?

        opts[:locale] = request_locale unless skip_locale?

        opts[:script_name] = relative_url_root if relative_url_root?

        router_name = Devise.mappings[scope].router_name || Devise.available_router_name
        context = send(router_name)

        if context.respond_to?(route)
          context.send(route, opts)
        elsif respond_to?(:root_url)
          root_url(opts)
        else
          "/"
        end
      end

      def request_locale
        @request_locale ||= request.params[:locale]
      end

      def skip_locale?
        request_locale.nil?
      end

      def available_locales
        @available_locales ||= (current_organization || Decidim).public_send(:available_locales)
      end

      def default_locale
        @default_locale ||= (current_organization || Decidim).public_send(:default_locale)
      end

      def current_organization
        warden.env["decidim.current_organization"]
      end

      def current_user
        warden.user
      end
  end
end
