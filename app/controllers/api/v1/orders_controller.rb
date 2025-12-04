class Api::V1::OrdersController < ApplicationController
  before_action :authenticate_customer, only: [:create]
  
  def create
    validation_service = ApiValidationService.new(@customer, order_params)
    
    unless validation_service.validate
      return render json: { errors: validation_service.errors }, status: :unprocessable_entity
    end
    
    order = @customer.orders.build(
      order_number: order_params['order_number'],
      airway_bill_number: order_params['airway_bill_number'],
      order_data: order_params,
      status: 'pending'
    )
    
    if order.save
      # Create order items
      order_params['items'].each do |item_data|
        sku = Sku.find_by(sku_code: item_data['sku_code'])
        order.order_items.create!(
          sku: sku,
          quantity: item_data['quantity'].to_i
        )
      end
      
      # Process order asynchronously
      order.process!
      
      render json: {
        order: order_serializer(order),
        message: "Order received and processing started"
      }, status: :created
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def show
    order = Order.find(params[:id])
    render json: { order: order_serializer(order) }
  end
  
  def index
    orders = Order.includes(:customer, :order_items, :picking_slips)
                  .order(created_at: :desc)
                  .limit(100)
    
    render json: {
      orders: orders.map { |o| order_serializer(o) }
    }
  end
  
  def reprocess
    order = Order.find(params[:id])
    picking_strategy = params[:picking_strategy] || 'auto'
    
    # Reset order items
    order.order_items.update_all(
      quantity_from_robot: 0,
      quantity_from_bin: 0,
      status: 'pending'
    )
    
    # Release inventory
    order.order_items.each do |item|
      if item.quantity_from_robot > 0
        item.sku.robot_location&.release(item.quantity_from_robot)
      end
      item.sku.bin_locations.each do |bin|
        bin.release(bin.reserved_quantity) if bin.reserved_quantity > 0
      end
    end
    
    # Reprocess
    service = OrderProcessingService.new(order)
    if service.process(picking_strategy: picking_strategy)
      render json: {
        order: order_serializer(order.reload),
        message: "Order reprocessed successfully"
      }
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end
  
  def reprint
    order = Order.find(params[:id])
    picking_slip = order.picking_slips.last
    
    if picking_slip
      picking_slip.print!
      render json: {
        message: "Reprint request sent",
        picking_slip: {
          id: picking_slip.id,
          slip_number: picking_slip.slip_number,
          status: picking_slip.status
        }
      }
    else
      render json: { error: "No picking slip found for this order" }, status: :not_found
    end
  end
  
  private
  
  def authenticate_customer
    api_key = request.headers['X-API-Key'] || params[:api_key]
    @customer = Customer.find_by(api_key: api_key)
    
    unless @customer&.active?
      render json: { error: "Invalid or inactive API key" }, status: :unauthorized
    end
  end
  
  def order_params
    params.require(:order).permit(:order_number, :airway_bill_number, items: [:sku_code, :quantity])
  end
  
  def order_serializer(order)
    {
      id: order.id,
      order_number: order.order_number,
      airway_bill_number: order.airway_bill_number,
      status: order.status,
      customer: {
        id: order.customer.id,
        name: order.customer.name
      },
      items: order.order_items.map do |item|
        {
          id: item.id,
          sku_code: item.sku.sku_code,
          sku_name: item.sku.name,
          quantity: item.quantity,
          quantity_from_robot: item.quantity_from_robot,
          quantity_from_bin: item.quantity_from_bin,
          status: item.status
        }
      end,
      picking_slips: order.picking_slips.map do |slip|
        {
          id: slip.id,
          slip_number: slip.slip_number,
          status: slip.status,
          printed_at: slip.printed_at
        }
      end,
      created_at: order.created_at,
      processed_at: order.processed_at
    }
  end
end


