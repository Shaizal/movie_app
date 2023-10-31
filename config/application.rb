require_relative "boot"

require "rails/all"
# config/application.rb
require 'phony_rails'


Bundler.require(*Rails.groups)

module MovieApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.

    # Add the following line to specify assets to precompile for the production environment.
    config.assets.precompile += %w( movie_details.js )
    config.action_view.form_with_generates_remote_forms = false

    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
