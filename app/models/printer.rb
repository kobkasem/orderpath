class Printer < ApplicationRecord
  has_many :picking_slips, dependent: :nullify
  
  validates :name, presence: true
  validates :ip_address, presence: true, format: { with: /\A(\d{1,3}\.){3}\d{1,3}\z/ }
  validates :port, presence: true, numericality: { greater_than: 0, less_than: 65536 }
  validates :printer_type, inclusion: { in: %w[picking_slip label] }
  
  scope :active, -> { where(active: true) }
  scope :for_type, ->(type) { where(printer_type: type) }
  
  def print_url
    "http://#{ip_address}:#{port}"
  end
end


