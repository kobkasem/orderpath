require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Orderpath
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = true
    config.time_zone = 'UTC'
    
    # Allow Rails to start even if database is not connected
    config.active_record.legacy_connection_handling = false
    
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


