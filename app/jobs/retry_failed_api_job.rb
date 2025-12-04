class RetryFailedApiJob < ApplicationJob
  queue_as :default
  
  def perform(api_log_id)
    api_log = ApiLog.find(api_log_id)
    
    case api_log.api_type
    when 'robot_pick'
      retry_robot_pick(api_log)
    when 'printer'
      retry_printer(api_log)
    end
  end
  
  private
  
  def retry_robot_pick(api_log)
    order_item = OrderItem.joins(:order)
                          .where(orders: { id: api_log.order_id })
                          .where('quantity_from_robot > 0')
                          .first
    
    return unless order_item
    
    RobotPickingService.new(order_item).send_pick_command
  end
  
  def retry_printer(api_log)
    picking_slip = PickingSlip.joins(:order)
                              .where(orders: { id: api_log.order_id })
                              .last
    
    return unless picking_slip
    
    PrinterService.new(picking_slip).print
  end
end


