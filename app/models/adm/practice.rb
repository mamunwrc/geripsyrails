class Adm::Practice < ApplicationRecord
  audited

  has_secure_token :remit_token

  enum practice_type: %i(solo group ipa), _prefix: true
  enum state: US_STATES.map(&:last), _prefix: true
  enum email_format: %i(pdf docx), _prefix: true

  has_many :users, class_name: 'Usr::User'
  has_many :providers, class_name: 'Usr::Provider'
  has_many :facilities
  has_many :patients, class_name: 'Pat::Patient'
  has_one :admin, class_name: 'Usr::Admin'
  has_many :reviewers, class_name: 'Usr::Reviewer'
  has_many :encounters, through: :patients, class_name: 'Enc::Encounter'

  validates :name, presence: true
  validates :tax_number, length: { maximum: 30 }
end

