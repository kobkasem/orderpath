class InventoryLocation < ApplicationRecord
  belongs_to :sku
  
  validates :location_type, presence: true, inclusion: { in: %w[robot bin] }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved_quantity, numericality: { greater_than_or_equal_to: 0 }
  
  validate :reserved_not_exceed_quantity
  
  def available_quantity
    quantity - reserved_quantity
  end
  
  def reserve(amount)
    return false if available_quantity < amount
    increment!(:reserved_quantity, amount)
    true
  end
  
  def release(amount)
    return false if reserved_quantity < amount
    decrement!(:reserved_quantity, amount)
    true
  end
  
  def allocate(amount)
    return false if available_quantity < amount
    increment!(:reserved_quantity, amount)
    decrement!(:quantity, amount)
    true
  end
  
  private
  
  def reserved_not_exceed_quantity
    if reserved_quantity > quantity
      errors.add(:reserved_quantity, "cannot exceed available quantity")
    end
  end
end


