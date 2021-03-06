# frozen_string_literal: true

module Decidim
  # A Helper to render the Call To Action button.
  module CtaButtonHelper
    # Renders the Call To Action button. Link and text can be configured
    # per organization.
    def cta_button
      button_text = translated_attribute(current_organization.cta_button_text).presence || t("decidim.pages.home.hero.participate")

      link_to button_text, cta_button_path, class: "hero-cta button large button--sc"
    end

    # Finds the CTA button path to reuse it in other places.
    def cta_button_path
      if current_organization.cta_button_path.present?
        url = current_organization.cta_button_path
        url_opts = controller.default_url_options
        url += "?#{url_opts.to_query}" unless url_opts.empty?
        url
      elsif Decidim::ParticipatoryProcess.where(organization: current_organization).published.any?
        decidim_participatory_processes.participatory_processes_path
      elsif current_user
        decidim.account_path
      else
        decidim.new_user_registration_path
      end
    end
  end
end
