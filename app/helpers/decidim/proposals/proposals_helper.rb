# frozen_string_literal: true

module Decidim
  module Proposals
    # Custom helpers, scoped to the proposals engine.
    #
    module ProposalsHelper
      def current_category
        if filter.category_id.is_a?(String) && !filter.category_id.empty?
          Decidim::Category.find_by(id: filter.category_id)
        end
      end
    end
  end
end
