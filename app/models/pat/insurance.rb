class Pat::Insurance < ApplicationRecord
  audited

  include HealthpacCode

  MEDICARE_GLOBAL_ID = 999
  OTHER_INSURANCE_ID = 404
  MEDICARE_IDS = [1, 2, 47]

  hp_code_base 'INS'
  hp_code_key :hp_id_code

  validates :name, presence: true, uniqueness: true

  default_scope  { order(:name) }
  scope :medicare, -> { where(hp_id_code: MEDICARE_IDS) }
  scope :not_medicare, -> { where.not(hp_id_code: MEDICARE_IDS) }

  attr_accessor :incoming_hp_code

  before_validation :parse_incoming_hp_code
  after_save :assign_unique_hp_id_code # TODO: temp fix until we eliminate this field

  # associate insurance providers with their payerids
  def self.import_payerids!(file_path = Rails.root.join('db', 'payers', 'payerid.csv'))
    require 'csv'

    headers = []

    id_col = 0
    payer_id_col = 3

    transaction do
      CSV.foreach(file_path) do |row|
        if headers.empty?
          headers = row
          raise "Malformed headers: #{headers}" if !(headers[id_col].casecmp?('id') && headers[payer_id_col].casecmp?('payerid'))
          next
        end

        Pat::Insurance.where(id: row[id_col]).update(payerid: row[payer_id_col])
      end
    end

    nil
  end

  def medicare?
    hp_id_code.in? MEDICARE_IDS
  end

  def medicaid?
    hp_id_code == 3
  end

  def type_name
    (medicare? && 'medicare') ||
      (medicare_hmo? && 'medicare_hmo') ||
      (medicaid? && 'medicaid') ||
      nil
  end

  private

  def assign_unique_hp_id_code
    if self.hp_id_code.blank?
      self.update_column(:hp_id_code, Pat::Insurance.maximum(:hp_id_code) + 1)
    end
  end

  def parse_incoming_hp_code
    if incoming_hp_code
      self.hp_id_code = incoming_hp_code.to_s.gsub(/\D/, '').to_i
    end
  end
end
