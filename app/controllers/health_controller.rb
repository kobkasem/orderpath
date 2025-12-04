# Ultra-simple healthcheck controller for Railway
# This endpoint has ZERO dependencies - no database, no models, nothing
class HealthController < ActionController::API
  def index
    # Return immediately without any database queries or model loading
    render json: { status: 'ok' }, status: :ok
  end
end

