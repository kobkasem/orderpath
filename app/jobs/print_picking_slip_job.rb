class PrintPickingSlipJob < ApplicationJob
  queue_as :default
  
  retry_on StandardError, wait: 5.seconds, attempts: 3
  
  def perform(picking_slip_id)
    picking_slip = PickingSlip.find(picking_slip_id)
    
    service = PrinterService.new(picking_slip)
    service.print
  rescue => e
    picking_slip.mark_failed!(e.message)
    raise e
  end
end


