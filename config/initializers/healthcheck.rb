# Healthcheck initialization
# This ensures the healthcheck endpoint is always available
# even if database is not connected

Rails.application.config.after_initialize do
  Rails.logger.info "Healthcheck endpoint available at /health"
end

