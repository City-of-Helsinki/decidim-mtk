class CurrentSpaceMiddleware
  # Initializes the Rack Middleware.
  #
  # app - The Rack application
  def initialize(app)
    @app = app
  end

  # Main entry point for a Rack Middleware.
  #
  # env - A Hash.
  def call(env)
    # Do not apply the hack for admin paths
    request = ActionDispatch::Request.new(env)
    if request.path =~ /\/admin\/.*/
      return @app.call(env)
    end

    # "Locks" all other routes to the defined main process.
    organization = env["decidim.current_organization"]
    if organization
      # Set the process
      process = Decidim::ParticipatoryProcess.find_by_id(
        Rails.application.config.process_id
      )
      env["decidim.current_participatory_space"] = process

      if process
        component = process.components.where(manifest_name: 'proposals').first
        env["decidim.current_component"] = component
      end
    end

    @app.call(env)
  end
end
