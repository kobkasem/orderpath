class Sku < ApplicationRecord
  has_many :inventory_locations, dependent: :destroy
  has_many :order_items, dependent: :destroy
  
  validates :sku_code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :category, presence: true
  
  def available_quantity(location_type)
    inventory_locations
      .where(location_type: location_type)
      .sum { |loc| loc.quantity - loc.reserved_quantity }
  end
  
  def total_available_quantity
    inventory_locations.sum { |loc| loc.quantity - loc.reserved_quantity }
  end
  
  def robot_location
    inventory_locations.find_by(location_type: 'robot')
  end
  
  def bin_locations
    inventory_locations.where(location_type: 'bin')
  end
end


