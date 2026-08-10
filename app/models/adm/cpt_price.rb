class Adm::CptPrice < ApplicationRecord
  validates :cpt_code, :price, presence: true
  validates :cpt_code, uniqueness: true
end

