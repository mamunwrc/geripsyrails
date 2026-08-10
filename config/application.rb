require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GeriPsy
  class Application < Rails::Application
    VERSION = "2023.12.11.0"

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.assets.paths << Rails.root.join("vendor","assets","bower_components")
    config.assets.paths << Rails.root.join("vendor","assets","bower_components","bootstrap-sass-official","assets","fonts")

    config.assets.precompile << %r(.*.(?:eot|svg|ttf|woff|woff2)$)
    config.assets.precompile += %w(angular-material.min.css)
    config.to_prepare do
      DeviseController.respond_to :html, :json
    end

    config.active_job.queue_adapter = :sidekiq

    config.action_dispatch.show_exceptions = false
    config.filter_parameters << :password
  end
end
