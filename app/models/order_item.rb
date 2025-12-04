class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :sku
  has_many :picking_slip_items, dependent: :destroy
  
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending allocated picked completed] }
  
  def total_allocated
    quantity_from_robot + quantity_from_bin
  end
  
  def fully_allocated?
    total_allocated >= quantity
  end
end


