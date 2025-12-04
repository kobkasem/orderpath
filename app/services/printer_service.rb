class PrinterService
  attr_reader :picking_slip, :printer
  
  def initialize(picking_slip, printer = nil)
    @picking_slip = picking_slip
    @printer = printer || picking_slip.printer || Printer.active.for_type('picking_slip').first
  end
  
  def print
    raise "No printer available" unless printer
    raise "Printer is not active" unless printer.active?
    raise "No slip content to print" if picking_slip.slip_content.blank?
    
    begin
      # Send print job to printer via IP
      response = HTTParty.post(
        printer.print_url,
        body: format_for_printer(picking_slip.slip_content),
        headers: {
          'Content-Type' => 'text/plain'
        },
        timeout: 10
      )
      
      if response.success?
        picking_slip.mark_printed!
        log_api_call('success', response.code)
      else
        picking_slip.mark_failed!("Printer returned error: #{response.code}")
        log_api_call('failed', response.code, "HTTP #{response.code}")
      end
    rescue => e
      picking_slip.mark_failed!(e.message)
      log_api_call('failed', nil, e.message)
      raise e
    end
  end
  
  private
  
  def format_for_printer(content)
    # Add printer-specific formatting if needed
    # This is a basic implementation - you may need to adjust based on your printer's requirements
    content
  end
  
  def log_api_call(status, status_code, error_message = nil)
    picking_slip.order.api_logs.create!(
      api_type: 'printer',
      endpoint: printer.print_url,
      method: 'POST',
      request_data: { slip_number: picking_slip.slip_number },
      response_data: { status: status },
      status_code: status_code,
      status: status,
      error_message: error_message,
      sent_at: Time.current
    )
  end
end


