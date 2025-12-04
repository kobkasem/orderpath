class OrderProcessingService
  attr_reader :order, :errors
  
  def initialize(order)
    @order = order
    @errors = []
  end
  
  def process(picking_strategy: 'auto')
    return false unless validate_order
    
    ActiveRecord::Base.transaction do
      allocate_inventory(picking_strategy)
      create_picking_slip
      send_robot_commands if needs_robot_picking?
      mark_order_completed
    end
    
    true
  rescue => e
    @errors << e.message
    order.mark_failed!(e.message)
    false
  end
  
  private
  
  def validate_order
    if order.order_items.empty?
      @errors << "Order has no items"
      return false
    end
    
    order.order_items.each do |item|
      unless item.sku.present?
        @errors << "SKU not found for item"
        return false
      end
    end
    
    true
  end
  
  def allocate_inventory(picking_strategy)
    order.order_items.each do |item|
      allocate_item_inventory(item, picking_strategy)
    end
  end
  
  def allocate_item_inventory(item, picking_strategy)
    sku = item.sku
    required_quantity = item.quantity
    
    # Store allocation details for picking slip generation
    item.instance_variable_set(:@allocated_bins, [])
    
    case picking_strategy
    when 'robot_only'
      allocate_from_robot(item, required_quantity)
    when 'bin_only'
      bins = allocate_from_bin(item, required_quantity)
      item.instance_variable_set(:@allocated_bins, bins.is_a?(Array) ? bins : [])
    when 'auto', 'both'
      allocate_auto(item, required_quantity)
    else
      allocate_auto(item, required_quantity)
    end
    
    item.update(status: 'allocated')
  end
  
  def allocate_auto(item, required_quantity)
    sku = item.sku
    
    # Check if quantity is below threshold for robot picking
    use_robot = required_quantity < sku.robot_threshold
    
    if use_robot
      # Try robot first
      robot_qty = allocate_from_robot(item, required_quantity)
      remaining = required_quantity - robot_qty
      
      # If robot doesn't have enough, use BIN
      if remaining > 0
        bins = allocate_from_bin(item, remaining)
        item.instance_variable_set(:@allocated_bins, bins.is_a?(Array) ? bins : [])
      end
    else
      # Quantity >= threshold, use BIN
      bins = allocate_from_bin(item, required_quantity)
      item.instance_variable_set(:@allocated_bins, bins.is_a?(Array) ? bins : [])
      remaining = required_quantity - (bins.is_a?(Array) ? bins.sum { |b| b[:quantity] } : 0)
      
      # If BIN doesn't have enough, try robot
      if remaining > 0
        robot_qty = allocate_from_robot(item, remaining)
      end
    end
  end
  
  def allocate_from_robot(item, quantity)
    sku = item.sku
    robot_location = sku.robot_location
    
    return 0 unless robot_location
    
    available = robot_location.available_quantity
    allocated = [available, quantity].min
    
    if allocated > 0
      robot_location.allocate(allocated)
      item.increment!(:quantity_from_robot, allocated)
    end
    
    allocated
  end
  
  def allocate_from_bin(item, quantity)
    sku = item.sku
    bin_locations = sku.bin_locations.order(:quantity)
    
    allocated = 0
    remaining = quantity
    allocated_bins = [] # Track which bins were used and how much
    
    bin_locations.each do |bin_loc|
      break if remaining <= 0
      
      available = bin_loc.available_quantity
      to_allocate = [available, remaining].min
      
      if to_allocate > 0
        bin_loc.allocate(to_allocate)
        allocated += to_allocate
        remaining -= to_allocate
        # Store reference to location and quantity allocated
        allocated_bins << { location: bin_loc, quantity: to_allocate }
      end
    end
    
    # Update item quantity
    item.increment!(:quantity_from_bin, allocated) if allocated > 0
    
    # Return both total allocated and bin details
    allocated_bins
  end
  
  def create_picking_slip
    printer = Printer.active.for_type('picking_slip').first
    picking_slip = order.picking_slips.create!(
      printer: printer,
      status: 'pending'
    )
    
    sequence = 1
    
    # Add BIN items first
    order.order_items.each do |item|
      next if item.quantity_from_bin == 0
      
      # Use stored allocation details if available
      allocated_bins = item.instance_variable_get(:@allocated_bins) || []
      
      if allocated_bins.any?
        # Use the tracked allocations
        allocated_bins.each do |bin_allocation|
          picking_slip.picking_slip_items.create!(
            order_item: item,
            location_type: 'bin',
            location_code: bin_allocation[:location].location_code,
            quantity: bin_allocation[:quantity],
            sequence: sequence
          )
          sequence += 1
        end
      else
        # Fallback: use current bin locations with reserved quantities
        item.sku.bin_locations.where('reserved_quantity > 0').each do |bin_loc|
          picking_slip.picking_slip_items.create!(
            order_item: item,
            location_type: 'bin',
            location_code: bin_loc.location_code,
            quantity: bin_loc.reserved_quantity,
            sequence: sequence
          )
          sequence += 1
        end
      end
    end
    
    # Then add robot items
    order.order_items.each do |item|
      next if item.quantity_from_robot == 0
      
      robot_loc = item.sku.robot_location
      if robot_loc
        picking_slip.picking_slip_items.create!(
          order_item: item,
          location_type: 'robot',
          location_code: robot_loc.location_code,
          quantity: item.quantity_from_robot,
          sequence: sequence
        )
        sequence += 1
      end
    end
    
    # Generate slip content
    generate_slip_content(picking_slip)
    picking_slip.save!
    
    # Print the slip
    picking_slip.print!
  end
  
  def generate_slip_content(picking_slip)
    content = []
    content << "=" * 60
    content << "PICKING SLIP: #{picking_slip.slip_number}"
    content << "ORDER: #{order.order_number}"
    content << "DATE: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
    content << "=" * 60
    content << ""
    
    # Group by location type
    bin_items = picking_slip.picking_slip_items.where(location_type: 'bin').order(:sequence)
    robot_items = picking_slip.picking_slip_items.where(location_type: 'robot').order(:sequence)
    
    if bin_items.any?
      content << "BIN LOCATION ITEMS:"
      content << "-" * 60
      bin_items.each do |item|
        content << "SKU: #{item.order_item.sku.sku_code} | Qty: #{item.quantity} | Location: #{item.location_code}"
      end
      content << ""
    end
    
    if robot_items.any?
      content << "ROBOT WAREHOUSE ITEMS:"
      content << "-" * 60
      robot_items.each do |item|
        content << "SKU: #{item.order_item.sku.sku_code} | Qty: #{item.quantity} | Location: #{item.location_code}"
      end
      content << ""
    end
    
    content << "=" * 60
    content << "TOTAL ITEMS: #{picking_slip.picking_slip_items.sum(:quantity)}"
    content << "=" * 60
    
    picking_slip.slip_content = content.join("\n")
  end
  
  def needs_robot_picking?
    order.order_items.any? { |item| item.quantity_from_robot > 0 }
  end
  
  def send_robot_commands
    order.order_items.each do |item|
      next if item.quantity_from_robot == 0
      
      RobotPickingService.new(item).send_pick_command
    end
  end
  
  def mark_order_completed
    order.mark_completed!
  end
end

