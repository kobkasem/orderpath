class RobotPickingService
  ROBOT_API_ENDPOINT = ENV['ROBOT_API_ENDPOINT'] || 'http://localhost:8080/api/pick'
  
  attr_reader :order_item
  
  def initialize(order_item)
    @order_item = order_item
  end
  
  def send_pick_command
    request_data = {
      sku_code: order_item.sku.sku_code,
      quantity: order_item.quantity_from_robot,
      location_code: order_item.sku.robot_location&.location_code,
      order_number: order_item.order.order_number
    }
    
    api_log = order_item.order.api_logs.create!(
      api_type: 'robot_pick',
      endpoint: ROBOT_API_ENDPOINT,
      method: 'POST',
      request_data: request_data,
      status: 'pending'
    )
    
    begin
      response = HTTParty.post(
        ROBOT_API_ENDPOINT,
        body: request_data.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        },
        timeout: 30
      )
      
      if response.success?
        api_log.mark_success!(response.parsed_response, response.code)
        order_item.update(status: 'picked')
      else
        api_log.mark_failed!("Robot API returned error: #{response.code} - #{response.body}")
        raise "Robot picking failed: #{response.code}"
      end
    rescue => e
      api_log.mark_failed!(e.message)
      raise e
    end
  end
end


