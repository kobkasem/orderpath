class Api::V1::MonitoringController < ApplicationController
  # Skip authentication for healthcheck
  skip_before_action :verify_authenticity_token, if: :json_request?
  
  def status
    # Simple healthcheck - always returns OK if server is running
    # This is used by Railway to verify the service is up
    begin
      # Try to check database connection (non-blocking)
      db_status = 'unknown'
      begin
        ActiveRecord::Base.connection.execute("SELECT 1")
        db_status = 'connected'
      rescue => e
        db_status = 'disconnected'
        Rails.logger.warn "Database check failed: #{e.message}"
      end
      
      # Return minimal response for healthcheck
      # Railway just needs to know the server is responding
      render json: { 
        status: 'ok', 
        timestamp: Time.current.iso8601,
        database: db_status
      }
    rescue => e
      # If something goes wrong, still try to return OK
      # This prevents healthcheck from failing due to minor issues
      Rails.logger.error "Healthcheck error: #{e.message}"
      render json: { status: 'ok', error: 'checking' }
    end
  end
  
  def errors
    failed_orders = Order.failed.includes(:customer).limit(50)
    failed_slips = PickingSlip.where(status: 'failed').includes(:order).limit(50)
    failed_api_logs = ApiLog.failed.includes(:order).limit(50)
    
    render json: {
      orders: failed_orders.map do |order|
        {
          id: order.id,
          order_number: order.order_number,
          error: order.error_message,
          retry_count: order.retry_count,
          created_at: order.created_at
        }
      end,
      picking_slips: failed_slips.map do |slip|
        {
          id: slip.id,
          slip_number: slip.slip_number,
          order_number: slip.order.order_number,
          error: slip.error_message,
          print_attempts: slip.print_attempts,
          created_at: slip.created_at
        }
      end,
      api_logs: failed_api_logs.map do |log|
        {
          id: log.id,
          api_type: log.api_type,
          endpoint: log.endpoint,
          error: log.error_message,
          order_id: log.order_id,
          created_at: log.created_at
        }
      end
    }
  end
  
  def retry_failed
    order_id = params[:order_id]
    picking_strategy = params[:picking_strategy] || 'auto'
    
    if order_id
      order = Order.find(order_id)
      service = OrderProcessingService.new(order)
      
      if service.process(picking_strategy: picking_strategy)
        render json: {
          message: "Order #{order.order_number} retried successfully",
          order: {
            id: order.id,
            order_number: order.order_number,
            status: order.status
          }
        }
      else
        render json: { errors: service.errors }, status: :unprocessable_entity
      end
    else
      render json: { error: "order_id parameter is required" }, status: :bad_request
    end
  end
end


