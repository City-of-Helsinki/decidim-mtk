# frozen_string_literal: true

class RegistrationsController < ::Decidim::Devise::RegistrationsController
  include UserNicknamer
end
