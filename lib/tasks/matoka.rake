# frozen_string_literal: true

namespace :matoka do

  # Usage example (would create 2 proposals):
  # bundle exec rails matoka:seed_proposals[2]
  desc 'Seed random proposals to the main component.'
  task :seed_proposals, [:howmany] => [:environment] do |t, args|
    howmany = args[:howmany].to_i || 0

    organization = Decidim::Organization.first
    unless organization
      raise "Organization does not exist!"
    end
    process = Decidim::ParticipatoryProcess.find_by_id(
      Rails.application.config.process_id
    )
    unless process
      raise "Process does not exist!"
    end
    component = process.components.where(manifest_name: 'proposals').first
    unless component
      raise "Component does not exist!"
    end

    orig_locale = Faker::Config.locale
    howmany.times do
      Faker::Config.locale = organization.available_locales.sample.to_sym
      proposal = Decidim::Proposals::Proposal.create!(
        component: component,
        category: process.categories.sample,
        scope: nil,
        title: Faker::Lorem.sentence(2),
        body: Faker::Lorem.paragraphs(2).join("\n"),
        state: nil,
        answer: nil,
        answered_at: Time.current,
        published_at: Time.current
      )
      puts "Created proposals with title: #{proposal.title}"
    end
    Faker::Config.locale = orig_locale

    puts "Seeded #{howmany} proposals."
  end
end
