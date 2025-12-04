class ProcessOrderJob < ApplicationJob
  queue_as :default
  
  retry_on StandardError, wait: 5.seconds, attempts: 3
  
  def perform(order_id, picking_strategy: 'auto')
    order = Order.find(order_id)
    
    service = OrderProcessingService.new(order)
    
    unless service.process(picking_strategy: picking_strategy)
      order.update(retry_count: order.retry_count + 1)
      raise "Order processing failed: #{service.errors.join(', ')}"
    end
  end
end


