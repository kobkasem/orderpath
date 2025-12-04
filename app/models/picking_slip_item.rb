class PickingSlipItem < ApplicationRecord
  belongs_to :picking_slip
  belongs_to :order_item
  
  validates :location_type, presence: true, inclusion: { in: %w[robot bin] }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :sequence, presence: true
end


