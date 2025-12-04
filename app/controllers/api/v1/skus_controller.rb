class Api::V1::SkusController < ApplicationController
  def index
    skus = Sku.includes(:inventory_locations).all
    render json: {
      skus: skus.map { |s| sku_serializer(s) }
    }
  end
  
  def show
    sku = Sku.includes(:inventory_locations).find(params[:id])
    render json: { sku: sku_serializer(sku) }
  end
  
  def create
    sku = Sku.new(sku_params)
    
    if sku.save
      render json: {
        sku: sku_serializer(sku),
        message: "SKU created successfully"
      }, status: :created
    else
      render json: { errors: sku.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    sku = Sku.find(params[:id])
    
    if sku.update(sku_params)
      render json: {
        sku: sku_serializer(sku),
        message: "SKU updated successfully"
      }
    else
      render json: { errors: sku.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def sku_params
    params.require(:sku).permit(:sku_code, :name, :category, :model, :robot_threshold, :active)
  end
  
  def sku_serializer(sku)
    {
      id: sku.id,
      sku_code: sku.sku_code,
      name: sku.name,
      category: sku.category,
      model: sku.model,
      robot_threshold: sku.robot_threshold,
      active: sku.active,
      inventory: {
        robot: {
          quantity: sku.available_quantity('robot'),
          location: sku.robot_location&.location_code
        },
        bin: {
          quantity: sku.available_quantity('bin'),
          locations: sku.bin_locations.map { |loc| { code: loc.location_code, quantity: loc.available_quantity } }
        },
        total: sku.total_available_quantity
      }
    }
  end
end


