# frozen_string_literal: true

class AccountController < Decidim::AccountController
  include UserNicknamer
end
