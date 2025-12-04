class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  has_many :picking_slips, dependent: :destroy
  has_many :api_logs, dependent: :destroy
  
  validates :order_number, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[pending processing completed failed] }
  
  scope :pending, -> { where(status: 'pending') }
  scope :processing, -> { where(status: 'processing') }
  scope :failed, -> { where(status: 'failed') }
  
  def process!
    update(status: 'processing')
    ProcessOrderJob.perform_later(id)
  end
  
  def mark_completed!
    update(status: 'completed', processed_at: Time.current)
  end
  
  def mark_failed!(error_message)
    update(status: 'failed', error_message: error_message)
  end
end


