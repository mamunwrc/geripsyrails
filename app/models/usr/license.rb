class Usr::License < ApplicationRecord
  audited

  enum state: US_STATES.map(&:last), _prefix: true

  belongs_to :provider

  validates :number, presence: true
  validates :state, inclusion: {in: states.keys, message: ->(record,error){
    val = record.instance_variable_get(:@__bad_state_val__)
    "#{val.inspect} is not a valid state"
  }}

  validates :state, uniqueness: { scope: :provider_id }

  def state=(val)
    super val
  rescue
    @__bad_state_val__ = val
    super nil
  end
end

