class Pat::Patient < ApplicationRecord
  audited

  has_many :encounters, class_name: "Enc::Encounter"
  has_many :notes, class_name: 'Pat::Note'
  belongs_to :facility, class_name: "Adm::Facility"
  belongs_to :practice, class_name: 'Adm::Practice'
  has_and_belongs_to_many :providers, class_name: "Usr::Provider", join_table: "patients_providers"

  has_many :_90791s, -> { signed.where(cpt_encounter_code: '90791') }, class_name: "Enc::Encounter"

  belongs_to :primary_insurance, class_name: 'Pat::Insurance', primary_key: :hp_id_code, optional: true
  belongs_to :secondary_insurance, class_name: 'Pat::Insurance', primary_key: :hp_id_code, optional: true
  belongs_to :tertiary_insurance, class_name: 'Pat::Insurance', primary_key: :hp_id_code, optional: true
  has_many :screenings, through: :encounters, class_name: "Enc::Screening"

  belongs_to :incident_to_provider, class_name: 'Usr::Provider', optional: true
  belongs_to :primary_provider, class_name: 'Usr::Provider', optional: true
  belongs_to :testing_provider, class_name: 'Usr::Provider', optional: true

  enum gender: %i(unknown male female), _prefix: true
  enum marital_status: %i(single married divorced widowed separated other unknown), _prefix: true
  enum status: %i(active inactive deceased unknown), _prefix: true
  enum race: %i(white black asian native_american pacific_islander unknown), _prefix: true
  enum language: %i(english spanish french russian unknown), _prefix: true

  validates :facility_id, presence: true
  validates :status, presence: true
  validates :facility_pos_code, presence: true

  before_validation do
    unless facility_pos_code.in?(FAC_POS_CODES)
      self.facility_pos_code = DEFAULT_FAC_POS
    end
  end

  before_validation :ensure_practice
  #before_save :ensure_dob_est
  before_save :ensure_dob_utc_midnight
  before_save :assign_medicare

  #after_save :associate_testing_provider, if: -> { !new_record? }
  after_save :assign_insurance_alert
  after_commit :no_provided_insurance_alert

  scope :active, -> { where status: 'active' }
  scope :inactive, -> { where.not status: 'active' }

  INFINITE_NEXT_TP = Time.parse('3000-01-01 00:00:00 +0000')
  INSURANCE_FIELDS = %i(primary_insurance_id secondary_insurance_id tertiary_insurance_id)
  FAC_POS_CODES    = [31, 32]
  DEFAULT_FAC_POS  = 31
  ALT_POS_CODE     = 32

  attr_accessor :service_dates

  # TODO: move to DB
  def avatar
    "avatars:svg-#{rand(15) + 1}"
  end

  def create_encounter_by_type(type)
    enc_klass = 
      case type.to_s
      when "TP"     then Enc::TreatmentPlan
      when "GBH1"   then Enc::EncounterGBH1
      #90839 = psychotherapy in crisis = basically 90791
      when "90839", %r(^907) then Enc::Encounter907xx
      when %r(^908) then Enc::Encounter908xx
      when %r(^9611) then Enc::Encounter9611x
      when %r(^9896) then Enc::Encounter9896x
      else          raise ArgumentError, "Unexpected encounter type '#{type}'"
      end

    unless Enc::Encounter9611x === enc_klass
      latest = encounters.signed.where.not(cpt_encounter_code: '96116').reorder(created_at: :desc, signed_on: :desc, id: :desc).first
    end

    enc_klass.create_from(latest, {
      patient_id: id,
      cpt_encounter_code: type,
      facility_pos_code: facility_pos_code
    })
  end

  def treatment_plans
    encounters.treatment_plans.signed.order("referral->>'service_date'")
  end

  def full_name
    [first_name, last_name].join ' '
  end

  def self.pending_tp
    zeroth, now, infinity = Time.at(0), DateTime.now, INFINITE_NEXT_TP
    pendings = active.where.not(next_tp: nil).reorder(:next_tp, :last_name)

    tier1 = pendings.where('next_tp BETWEEN ? AND ?', zeroth, now)
    tier2 = pendings.where('next_tp BETWEEN ? AND ?', infinity+1.second, infinity+10.year)
    tier3 = pendings.where('next_tp BETWEEN ? AND ?', now+1.second, infinity)

    tier1.union_all(tier2.union_all(tier3))
  end

  def assign_next_tp
    date =
      if latest = treatment_plans.signed.last
        # See FIXME in #needs_tp?
        if latest.service_date.respond_to?(:+)
          latest.service_date + 3.months
        end
      elsif sixth = encounters.signed.offset(5).first
        sixth.service_date + 3.months
      elsif (count = encounters.signed.count) > 0
        INFINITE_NEXT_TP + (10 - count).years
      end

    update(next_tp: date.midnight) if date
  end

  def needs_tp?
    # # > 3 month since last tp
    # if latest = treatment_plans.signed.last
    #   if latest.service_date.respond_to?(:<)
    #     latest.service_date < 3.months.ago
    #   else
    #     # FIXME
    #     # this scenario should never happen! an encounter cannot be signed
    #     # if missing data like service_date
    #     false #for now..
    #   end
    # else
    #   return false if encounters.signed.count.zero?
    #   encounters.signed.first.service_date < 3.months.ago && encounters.signed.count > 5
    # end

    next_tp and next_tp < Time.now
  end

  def facility_room
    room_num ? [facility.name, room_num].join('/') : facility.name
  end

  def insurance
    Hashie::Mash.new.tap do |mash|
      %i(primary secondary tertiary).each do |type|
        mash[type] = {
          insurer: send(:"#{type}_insurance"),
          number: send(:"#{type}_insurance_number")
        }
      end
    end
  end

  def has90791!
    update(has90791: true)
  end

  def update_primary_provider(cpt, covering, pro_id)
    # make sure the provider actually exists...
    return if providers.where(id: pro_id).count.zero?
    return if cpt == '90832' && covering
    update(primary_provider_id: pro_id)
  end

  def reprimarize!
    cur = primary_provider_id
    if enc = encounters.signed.not_covering.where(signed_by: provider_ids - [cur]).reorder('signed_on DESC').first
      self.primary_provider_id = enc.signed_by
    elsif pro = providers.where.not(id: cur).first
      self.primary_provider_id = pro.id
    else
      self.primary_provider_id = nil
    end
    save!
  end

  private

  # This will most likely never happen but just for sanity's sake...
  def ensure_practice
    if facility_id_changed?
      self.practice_id = facility.try(:practice_id)
    end
  end

  # FIXME super hackity hack
  # need a global fix for dates
  # def ensure_dob_est
  #   return unless dob.respond_to?(:hour)
  #   if dob.hour != 5
  #     self.dob += (5-dob.hour).hours
  #   end
  # end

  def ensure_dob_utc_midnight
    self.dob = dob.midnight unless dob.blank?
  end

  def assign_medicare
    %i(primary_insurance_id secondary_insurance_id tertiary_insurance_id).each do |insid|
      # Medicare was selected
      if send(insid) == ::Pat::Insurance::MEDICARE_GLOBAL_ID
        send("#{insid}=", facility.medicare_before_type_cast)
      end
    end
  end

  def assign_insurance_alert
    if INSURANCE_FIELDS.any? {|field| send(field) == ::Pat::Insurance::OTHER_INSURANCE_ID && send("#{field}_changed?") }
      needs_insurance_alert!
    end
  end

  def needs_insurance_alert!
    @__insurance_alert__ = true
  end

  def needs_insurance_alert?
    !!@__insurance_alert__
  end

  def no_provided_insurance_alert
    return unless ENV['INSURANCE_CONTACT_EMAIL']
    if needs_insurance_alert?
      InsuranceAlertJob.perform_later id
    end
  end

  def associate_testing_provider
    return true unless saved_change_to_attribute?(:testing_provider_id)

    prev_val = attribute_before_last_save(:testing_provider_id)

    if prev_val.nil?
      # in cases where #testing_provider_id is
      # set on patient create
      return unless testing_provider_id

      Usr::Provider.find(testing_provider_id).patients << self
    elsif testing_provider_id.nil?
      # dont remove patient if primary was somehow
      # marked as testing...
      return if primary_provider_id && primary_provider_id == prev_val

      Usr::Provider.find(prev_val).patients.delete(self)
    end
  end
end
