class ApiLog < ApplicationRecord
  belongs_to :order, optional: true
  
  validates :api_type, presence: true
  validates :status, inclusion: { in: %w[pending success failed] }
  
  scope :failed, -> { where(status: 'failed') }
  scope :pending, -> { where(status: 'pending') }
  
  def mark_success!(response_data, status_code = 200)
    update(
      status: 'success',
      response_data: response_data,
      status_code: status_code,
      sent_at: Time.current
    )
  end
  
  def mark_failed!(error_message)
    update(
      status: 'failed',
      error_message: error_message,
      sent_at: Time.current
    )
  end
end


