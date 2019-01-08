require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DecidimHkimatoka
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Configure an application wide address suffix to pass to the geocoder.
    # This is to make sure that the addresses are not incorrectly mapped outside
    # of the wanted area.
    config.address_suffix = 'Helsinki, Finland'

    # Tracking
    config.snoobi_account = nil

    # Hard code the "main" participatory process
    config.process_id = ENV.fetch("DECIDIM_PROCESS_ID") { 1 }

    config.external_links = {
      # After leaving the idea, the link to leave contact details for the draw
      draw_contact: 'https://response.questback.com/helsinginkaupunki/ideakilpailunarvonta',
      # If the user doesn't want to sign up for the service, where to link them
      alternative_idea_form: 'https://response.questback.com/helsinginkaupunki/idealomake',
    }

    # Hard code the categories to specific "handles" so that we can use them
    # to fetch the correct images
    config.category_handles = {
      clean:         ENV.fetch("DECIDIM_CATEGORY_ID_CLEAN") { 1 },
      sustainable:   ENV.fetch("DECIDIM_CATEGORY_ID_SUSTAINABLE") { 2 },
      creative:      ENV.fetch("DECIDIM_CATEGORY_ID_CREATIVE") { 3 },
      intelligent:   ENV.fetch("DECIDIM_CATEGORY_ID_INTELLIGENT") { 4 },
      fun:           ENV.fetch("DECIDIM_CATEGORY_ID_FUN") { 5 },
      sporty:        ENV.fetch("DECIDIM_CATEGORY_ID_SPORTY") { 6 },
      international: ENV.fetch("DECIDIM_CATEGORY_ID_INTERNATIONAL") { 7 },
      serviceminded: ENV.fetch("DECIDIM_CATEGORY_ID_SERVICEMINDED") { 8 },

      # These will not be active but they also don't cause any harm here
      agile:         ENV.fetch("DECIDIM_CATEGORY_ID_AGILE") { 9 },
      influential:   ENV.fetch("DECIDIM_CATEGORY_ID_INFLUENTIAL") { 10 },
      participatory: ENV.fetch("DECIDIM_CATEGORY_ID_PARTICIPATORY") { 11 },
    }.invert

    # Add the override translations to the load path
    config.i18n.load_path += Dir[
      Rails.root.join('config', 'locales', 'crowdin-master/*.yml').to_s,
      Rails.root.join('config', 'locales', 'overrides/*.yml').to_s,
    ]

    # Configure the CurrentSpaceMiddleware
    initializer "middleware" do |app|
      app.config.middleware.use CurrentSpaceMiddleware
    end

    initializer "helpers" do |app|
      # Hack to make the `decidim` helper available where needed
      Rails.application.routes.define_mounted_helper('decidim')
    end

    initializer "view_hooks" do
      # Reset the participatory space highlighted elements because we have
      # disabled modules
      hooks = Decidim.view_hooks.instance_variable_get(:@hooks)
      hooks[:participatory_space_highlighted_elements] = []
      Decidim.view_hooks.instance_variable_set(:@hooks, hooks)

      # Re-register the highlighted proposals element
      Decidim.view_hooks.register(:participatory_space_highlighted_elements, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
        published_components = Decidim::Component.where(participatory_space: view_context.current_participatory_space).published
        proposals = Decidim::Proposals::Proposal.published.not_hidden.except_withdrawn
                                                .where(component: published_components)
                                                .order_randomly(rand * 2 - 1)
                                                .limit(Decidim::Proposals.config.participatory_space_highlighted_proposals_limit)

        #next unless proposals.any?

        view_context.extend Decidim::Proposals::ApplicationHelper
        view_context.render(
          partial: "decidim/participatory_spaces/highlighted_proposals",
          locals: {
            proposals: proposals
          }
        )
      end
    end

    initializer "menu" do
      # Override the main menu
      Decidim::MenuRegistry.create(:menu)

      Decidim.menu :menu do |menu|
        menu.item I18n.t("menu.home", scope: "decidim"),
                  main_app.root_path,
                  position: 0,
                  active: :exact
        menu.item I18n.t("components.proposals.name_all", scope: "decidim"),
                  decidim_participatory_process_proposals.proposals_path,
                  position: 1,
                  active: /^\/proposals((?!\/new).)*$/

        if main_component && main_component.current_settings.creation_enabled?
          menu.item I18n.t("proposals.actions.new", scope: "decidim"),
                    decidim_participatory_process_proposals.new_proposal_path,
                    position: 1,
                    active: :inclusive
        end
      end
    end

    initializer "user_menu" do
      # Override the user menu
      Decidim::MenuRegistry.create(:user_menu)

      Decidim.menu :user_menu do |menu|
        menu.item t("account", scope: "layouts.decidim.user_profile"),
                  decidim.account_path,
                  position: 1.0,
                  active: :exact

        menu.item t("notifications_settings", scope: "layouts.decidim.user_profile"),
                  decidim.notifications_settings_path,
                  position: 1.1

        if user_groups.any?
          menu.item t("user_groups", scope: "layouts.decidim.user_profile"),
                    decidim.own_user_groups_path,
                    position: 1.3
        end

        menu.item t("my_data", scope: "layouts.decidim.user_profile"),
                  decidim.data_portability_path,
                  position: 1.4

        menu.item t("delete_my_account", scope: "layouts.decidim.user_profile"),
                  decidim.delete_account_path,
                  position: 999,
                  active: :exact
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Setup the model and form extensions
    initializer 'model_extensions' do |app|
      # Forms
      Decidim::AttachmentForm.send(:include, ImageAttachmentForm)
    end

    # Setup the correct omniauth providers
    initializer 'user_authentication' do |app|
      Decidim::User.send(:include, UserAuthentication)

      # The following hook is for the development environment and it is needed
      # to load the correct omniauth configurations to the Decidim::User model
      # BEFORE the routes are reloaded in Decidim::Core::Engine. Without this,
      # the extra omniauth authentication methods are lost during application
      # reloads as the Decidim::User class is reloaded during which the omniauth
      # configurations are overridden by the core class. After the override, the
      # routes are reloaded (before call to to_prepare) which causes the extra
      # configured methods to be lost.
      #
      # The load order is:
      # - Models, including Decidim::Core::Engine models (sets the omniauth back
      #   to Decidim defaults)
      # - ActionDispatch::Reloader - after_class_unload hook (below)
      # - Routes, including Decidim::Core::Engine routes (reloads the routes
      #   using the omniauth providers set by Decidim::Core)
      # - to_prepare hook (which would be the optimal place for this but too
      #   late in the load process)
      #
      # In case you are planning to change this, make sure that the following
      # works:
      # - Start the application with Tunnistamo omniauth method configured
      # - Load the login page and see that Tunnistamo is configured
      # - Make a change to any file under the `app` folder
      # - Reload the login page and see that Tunnistamo is configured
      #
      # This could be also fixed in the Decidim core by making the omniauth
      # providers configurable through the application configs. See:
      # https://github.com/decidim/decidim/blob/a40656/decidim-core/app/models/decidim/user.rb#L17
      #
      # NOTE: This problem only occurs when the models and routes are reloaded,
      #       i.e. in development environment.
      app.reloader.after_class_unload do
        Decidim::User.send(:include, UserAuthentication)
      end
    end

    initializer "default_form_builder" do |_app|
      ActionView::Base.default_form_builder = Helsinki::FormBuilder
    end

    # Without this, the stacktraces are silenced by our custom middleware.
    #
    # See:
    # https://stackoverflow.com/a/33658027
    initializer "stacktrace_silencers" do |app|
      app_dir = "#{app.root}/app"
      #raise app_dir.inspect
      exclude = Dir["#{app_dir}/*"].map do |dir|
        if File.directory?(dir) && dir !~ /middleware$/
          File.basename(dir)
        end
      end

      Rails.backtrace_cleaner.remove_silencers!
      Rails.backtrace_cleaner.add_silencer { |line|
        line !~ /^\/(#{exclude.compact.join("|")})/
      }
    end

    # See:
    # https://guides.rubyonrails.org/configuring.html#initialization-events
    #
    # Run before every request in development.
    config.to_prepare do
      # == Uploader extensions
      Decidim::AttachmentUploader.send(:include, AttachmentUploaderSizes)

      # Re-mount the attachment uploader with the specified changes
      Decidim::Attachment.mount_uploader(:file, Decidim::AttachmentUploader)
    end
  end
end
