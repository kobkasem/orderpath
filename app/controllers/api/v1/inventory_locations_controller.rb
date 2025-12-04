class Api::V1::InventoryLocationsController < ApplicationController
  def index
    sku = Sku.find(params[:sku_id])
    locations = sku.inventory_locations
    
    render json: {
      sku: {
        id: sku.id,
        sku_code: sku.sku_code,
        name: sku.name
      },
      locations: locations.map { |loc| inventory_location_serializer(loc) }
    }
  end
  
  private
  
  def inventory_location_serializer(location)
    {
      id: location.id,
      location_type: location.location_type,
      location_code: location.location_code,
      quantity: location.quantity,
      reserved_quantity: location.reserved_quantity,
      available_quantity: location.available_quantity
    }
  end
end


