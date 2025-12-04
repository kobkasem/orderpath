class PickingSlip < ApplicationRecord
  belongs_to :order
  belongs_to :printer, optional: true
  has_many :picking_slip_items, dependent: :destroy
  
  validates :slip_number, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[pending printed failed] }
  
  require 'securerandom'
  
  before_validation :generate_slip_number, on: :create
  
  def print!
    PrintPickingSlipJob.perform_later(id)
  end
  
  def mark_printed!
    update(status: 'printed', printed_at: Time.current)
  end
  
  def mark_failed!(error_message)
    increment!(:print_attempts)
    update(status: 'failed', error_message: error_message)
  end
  
  def items_by_location_type
    picking_slip_items.order(:sequence).group_by(&:location_type)
  end
  
  private
  
  def generate_slip_number
    self.slip_number ||= "PS-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.alphanumeric(8).upcase}"
  end
end

