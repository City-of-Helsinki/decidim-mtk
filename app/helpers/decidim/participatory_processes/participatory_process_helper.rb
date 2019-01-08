# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Helpers related to the Participatory Process layout.
    module ParticipatoryProcessHelper
      # Public: Returns the dates for a step in a readable format like
      # "2016-01-01 - 2016-02-05".
      #
      # participatory_process_step - The step to format to
      #
      # Returns a String with the formatted dates.
      def step_dates(participatory_process_step)
        dates = [participatory_process_step.start_date, participatory_process_step.end_date]
        dates.map { |date| date ? localize(date.to_date, format: :default) : "?" }.join(" - ")
      end

      def category_link(category, options={})
        category_link = decidim_participatory_process_proposals.proposals_path(
          filter: {category_id: category.id}
        )
        link_to category_link, options do
          yield
        end
      end

      def category_ideas_count(category)
        if main_component
          Decidim::Proposals::Proposal.joins(:category)
            .except_rejected.except_withdrawn
            .where(
              decidim_component_id: main_component.id,
              decidim_categories: {id: category.id}
            ).count
        else
          0
        end
      end

      def total_ideas_count
        Decidim::Proposals::Proposal
          .except_rejected.except_withdrawn
          .where(decidim_component_id: main_component.id)
          .count
      end
    end
  end
end
