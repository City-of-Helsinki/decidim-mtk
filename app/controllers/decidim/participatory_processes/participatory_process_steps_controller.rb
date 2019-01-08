# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A controller that holds the logic to show ParticipatoryProcessSteps in a
    # public layout.
    class ParticipatoryProcessStepsController < Decidim::ParticipatoryProcesses::ApplicationController
      include ParticipatorySpaceContext
      include Rails.application.routes.url_helpers # Fix the modified routes
      participatory_space_layout only: :index

      def index; end

      private

      def organization_participatory_processes
        @organization_participatory_processes ||= OrganizationParticipatoryProcesses.new(current_organization).query
      end

      def current_participatory_space
        request.env["decidim.current_participatory_space"]
      end
    end
  end
end
