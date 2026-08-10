class Pat::Note < ApplicationRecord
  belongs_to :patient, class_name: 'Pat::Patient'
  belongs_to :user, class_name: 'Usr::User'

  validates :patient, presence: true
  validates :user, presence: true
end
