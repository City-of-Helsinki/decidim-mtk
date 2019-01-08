Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Customized Decidim core routes
  # Mount the Decidim routes manually to modify them more easily
  mount Decidim::Api::Engine => "/api"
  mount Decidim::Admin::Engine => "/admin"
  mount Decidim::System::Engine => "/system"

  # Root at the top so that the engines won't override this
  root to: "home#index"

  devise_for :users,
             class_name: "Decidim::User",
             module: :devise,
             router_name: :decidim,
             controllers: {
               invitations: "decidim/devise/invitations",
               sessions: "decidim/devise/sessions",
               confirmations: "confirmations",
               registrations: "registrations",
               passwords: "decidim/devise/passwords",
               omniauth_callbacks: "devise/omniauth_registrations"
             }

  devise_scope :user do
    post "omniauth_registrations" => "devise/omniauth_registrations#create"
  end

  authenticate(:user) do
    resource :account, only: [:show, :update, :destroy], controller: "account" do
      member do
        get :delete
      end
    end
  end

  scope module: 'decidim' do
    resource :locale, only: [:create]

    # CUSTOM START
    # Mount the needed component manifests to the root
    manifests = Decidim.component_manifests.select do |manifest|
      manifest.name == :proposals
    end
    manifests.each do |manifest|
      next unless manifest.engine

      constraints Decidim::ParticipatoryProcesses::CurrentComponent.new(manifest) do
        mount manifest.engine, at: "/", as: "decidim_participatory_process_#{manifest.name}"
      end
    end
    # CUSTOM END

    mount Decidim::Verifications::Engine, at: "/", as: "decidim_verifications"

    Decidim.global_engines.each do |name, engine_data|
      mount engine_data[:engine], at: engine_data[:at], as: name
    end

    authenticate(:user) do
      resources :conversations, only: [:new, :create, :index, :show, :update], controller: "messaging/conversations"
      resources :notifications, only: [:index, :destroy] do
        collection do
          delete :read_all
        end
      end
      resource :notifications_settings, only: [:show, :update], controller: "notifications_settings"
      resources :own_user_groups, only: [:index]

      get "/newsletters_opt_in/:token", to: "newsletters_opt_in#update", as: :newsletters_opt_in

      resource :data_portability, only: [:show], controller: "data_portability" do
        member do
          post :export
          get :download_file
        end
      end

      get "/authorization_modals/:authorization_action/f/:component_id(/:resource_name/:resource_id)", to: "authorization_modals#show", as: :authorization_modal

      resources :groups, except: [:destroy, :index, :show] do
        resources :join_requests, only: [:create, :update, :destroy], controller: "user_group_join_requests"
        resources :invites, only: [:index, :create, :update, :destroy], controller: "group_invites"
        resources :users, only: [:index, :destroy], controller: "group_members", as: "manage_users" do
          member do
            post :promote
          end
        end
        resources :admins, only: [:index], controller: "group_admins", as: "manage_admins" do
          member do
            post :demote
          end
        end

        member do
          delete :leave
        end
      end
    end

    resources :profiles, only: [:show], param: :nickname, constraints: { nickname: %r{[^\/]+} }, format: false
    scope "/profiles/:nickname", format: false, constraints: { nickname: %r{[^\/]+} } do
      get "following", to: "profiles#following", as: "profile_following"
      get "followers", to: "profiles#followers", as: "profile_followers"
      get "badges", to: "profiles#badges", as: "profile_badges"
      get "groups", to: "profiles#groups", as: "profile_groups"
      get "members", to: "profiles#members", as: "profile_members"
    end

    resources :pages, only: [:index, :show], format: false

    get "/search", to: "searches#index", as: :search

    get :organization_users, to: "users#index"

    get "/scopes/picker", to: "scopes#picker", as: :scopes_picker

    get "/static_map", to: "static_map#show", as: :static_map
    get "/cookies/accept", to: "cookie_policy#accept", as: :accept_cookies
    put "/pages/terms-and-conditions/accept", to: "tos#accept_tos", as: :accept_tos

    match "/404", to: "errors#not_found", via: :all
    match "/500", to: "errors#internal_server_error", via: :all

    resource :follow, only: [:create, :destroy]
    resource :report, only: [:create]

    resources :newsletters, only: [:show] do
      get :unsubscribe, on: :collection
    end

    use_doorkeeper do
      skip_controllers :applications, :authorized_applications
    end

    scope :oauth do
      get "/me" => "doorkeeper/credentials#me"
    end

    resources :participatory_process_steps, only: [:index], path: "steps", controller: 'participatory_processes/participatory_process_steps'
  end
end
