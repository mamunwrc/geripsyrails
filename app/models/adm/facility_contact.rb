class Adm::FacilityContact < ApplicationRecord
  audited

  belongs_to :facility

  enum export_format: %i(pdf docx), _prefix: true
  enum export_type: %i(partial full), _prefix: true

  validates :name, presence: true
  validates :email, presence: true, email_format: { message: 'is not a valid email address' }

  scope :active, -> {where(active: true)}
end
