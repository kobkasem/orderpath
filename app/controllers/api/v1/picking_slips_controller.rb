class Api::V1::PickingSlipsController < ApplicationController
  def index
    picking_slips = PickingSlip.includes(:order, :printer, :picking_slip_items).order(created_at: :desc).limit(100)
    render json: {
      picking_slips: picking_slips.map { |ps| picking_slip_serializer(ps) }
    }
  end
  
  def show
    picking_slip = PickingSlip.includes(:order, :printer, :picking_slip_items).find(params[:id])
    render json: { picking_slip: picking_slip_serializer(picking_slip) }
  end
  
  def reprint
    picking_slip = PickingSlip.find(params[:id])
    picking_slip.print!
    
    render json: {
      message: "Reprint request sent",
      picking_slip: picking_slip_serializer(picking_slip.reload)
    }
  end
  
  private
  
  def picking_slip_serializer(picking_slip)
    {
      id: picking_slip.id,
      slip_number: picking_slip.slip_number,
      order_number: picking_slip.order.order_number,
      status: picking_slip.status,
      printer: picking_slip.printer ? {
        id: picking_slip.printer.id,
        name: picking_slip.printer.name,
        ip_address: picking_slip.printer.ip_address
      } : nil,
      items: picking_slip.picking_slip_items.order(:sequence).map do |item|
        {
          sku_code: item.order_item.sku.sku_code,
          quantity: item.quantity,
          location_type: item.location_type,
          location_code: item.location_code,
          sequence: item.sequence
        }
      end,
      print_attempts: picking_slip.print_attempts,
      printed_at: picking_slip.printed_at,
      created_at: picking_slip.created_at
    }
  end
end


