class ApiValidationService
  attr_reader :customer, :order_data, :errors
  
  def initialize(customer, order_data)
    @customer = customer
    @order_data = order_data
    @errors = []
  end
  
  def validate
    validate_customer
    validate_order_structure
    validate_order_items
    errors.empty?
  end
  
  private
  
  def validate_customer
    unless customer&.active?
      @errors << "Customer is not active or not found"
    end
    
    unless customer&.validate_api_endpoint
      @errors << "Customer API endpoint is invalid"
    end
  end
  
  def validate_order_structure
    unless order_data.is_a?(Hash)
      @errors << "Order data must be a JSON object"
      return
    end
    
    unless order_data['order_number'].present?
      @errors << "Order number is required"
    end
    
    unless order_data['items'].is_a?(Array) && order_data['items'].any?
      @errors << "Order must have at least one item"
    end
  end
  
  def validate_order_items
    return unless order_data['items'].is_a?(Array)
    
    order_data['items'].each_with_index do |item, index|
      unless item['sku_code'].present?
        @errors << "Item #{index + 1}: SKU code is required"
      end
      
      unless item['quantity'].present? && item['quantity'].to_i > 0
        @errors << "Item #{index + 1}: Valid quantity is required"
      end
      
      # Check if SKU exists
      if item['sku_code'].present?
        sku = Sku.find_by(sku_code: item['sku_code'])
        unless sku&.active?
          @errors << "Item #{index + 1}: SKU #{item['sku_code']} not found or inactive"
        end
      end
    end
  end
end


