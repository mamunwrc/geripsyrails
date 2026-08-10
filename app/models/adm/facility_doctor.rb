class Adm::FacilityDoctor < ApplicationRecord
  audited

  belongs_to :facility

  validates :name, presence: true, uniqueness: { scope: :facility_id}
end
