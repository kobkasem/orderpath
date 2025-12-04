require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Orderpath
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = true
    config.time_zone = 'UTC'
    
    # Don't verify database connection on startup (allows app to start even if DB not ready)
    config.active_record.verify_foreign_keys = false
    
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end
  end
end


