# Simple healthcheck controller for Railway
# This is a minimal endpoint that just confirms the server is running
class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def index
    render json: { status: 'ok', service: 'orderpath', timestamp: Time.current.iso8601 }
  end
end

