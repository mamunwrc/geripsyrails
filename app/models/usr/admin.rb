class Usr::Admin < ApplicationRecord
  audited

  has_one :user, as: :meta, dependent: :destroy
  accepts_nested_attributes_for :user

  belongs_to :practice, class_name: 'Adm::Practice'
  has_many :patients, through: :practice, class_name: 'Pat::Patient'
  has_many :encounters, through: :patients, class_name: 'Enc::Encounter'
  has_many :providers, through: :practice, class_name: 'Usr::Provider'
  has_many :facilities, through: :practice, class_name: 'Adm::Facility'

  validates :practice_id, presence: true

  def bookkeeping(opts={})
    opts[:signed] = 'Y'
    encs = user.encounter_filter opts
    encs = encs.where.not(cpt_encounter_code: 'TP')
    encs.includes(:patient).inject({}) do |hash, enc|
      hash.tap do |h|
        type = h[enc.encounter_type] ||= {count: 0, rate: 0}
        type[:count] += 1
        type[:rate] += enc.reimbursement_rate
      end
    end
  end
end

