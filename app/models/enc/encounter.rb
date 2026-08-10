class Enc::Encounter < ApplicationRecord
  audited

  NotValidForChargeError = Class.new(StandardError)
  AlreadyShippedToHpError = Class.new(StandardError)

  belongs_to :incident_to_provider, class_name: 'Usr::Provider', foreign_key: :incident_to_provider_id, optional: true
  belongs_to :patient, class_name: "Pat::Patient"
  belongs_to :signer, class_name: 'Usr::Provider', foreign_key: :signed_by, optional: true

  has_many :providers, through: :patient, class_name: 'Usr::Provider'
  has_many :addendums, dependent: :destroy
  has_many :screenings, dependent: :destroy

  store :shipped_hp_billing, accessors: [ :filename, :xml ], coder: YAML

  accepts_nested_attributes_for :screenings, reject_if: :reject_screenings

  attr_accessor :certify
  attr_accessor :addendum, :addendum_user_id
  attr_accessor :group_session
  attr_accessor :validate_service_date

  CERTS = {
    initial: 'I certify that the above services were conducted as documented and that the patient provided assent for treatment.',
    followup: 'I certify that the above services were conducted as documented with a reasonable expectation of improvement and that the patient provided assent for treatment. In addition, I also certify that, in my professional opinion, the medical record supports that senile dementia has not produced a severe enough cognitive deficit to prevent psychotherapy from being effective.',
    group: 'I certify that the above services were conducted as documented and the patient participated in the group session. In addition, I also certify that, in my professional opinion, the medical record supports that senile dementia has not produced a severe enough cognitive defect to prevent psychotherapy from being effective.',
    tp: 'In my professional clinical opinion, the treatment plan documents that the patient continues to make progress toward treatment goals and is able to meaningfully benefit from psychotherapy and that the treatment is expected to improve the health status or function of the patient. Moreover, if treatment services were withdrawn it is reasonable to expect that the patient\'s condition may deteriorate, relapse further or require hospitalization.',
    incident_to: 'Spoke with patient and patient has given consent for “incident to” services to be provided by designated therapist as per discretion of myself as supervising provider.',
  }
  CERTS[:long] = CERTS[:followup]
  CERTS[:short] = CERTS[:initial]

  DATA_FIELDS = %i(
    tp_methods
    background_history
    certification
    diagnosis
    functional_status
    plan
    problem
    progress
    referral
    therapeutic_communication
    competency
    goals
    group_data
  ).each{|field| serialize field, HashSerializer }

  DATA_VALIDTORS = (DATA_FIELDS - %i(goals)).
    map{|f| "enc/#{f}_validator".classify.constantize }

  DATE_VALIDATORS = [Enc::ReferralValidator]

  TESTING_EVAL_CODES = %w(96116 96130 96132)

  before_save do
    if addendum
      addendums.build note: addendum, user_id: addendum_user_id
    end

    mdname = referral.try(:md_name)
    if mdname.try(:name) == "FREETEXT"
      doctor = patient.facility.doctors.find_or_create_by name: mdname["freetext"]
      referral.md_name = { val: doctor.name, name: doctor.id}
    end
  end

  include Enc::EncounterCertificationHelpers

  self.referral_base :referral
  self.referral_fields *%i(service_date order_date)

  before_save :capture_certification, if: -> { certify }
  before_save :ensure_dates_utc_midnight
  before_save :dedup_screenings

  MODIFIERABLE_CODES = %w(90832 90853)
  after_validation :assign_59_modifier, if: -> { certify && modifierable? }
  after_validation :assign_95_modifier, if: -> { certify }

  after_save :update_patient_pos, if: -> { certify }

  after_save do
    if certify
      # ensure patient is marked as having 90791
      patient.has90791! if !patient.has90791? and cpt_encounter_code == '90791'
      patient.update_primary_provider(cpt_encounter_code, referral.try(:covering), signed_by)

      patient.assign_next_tp
    end
  end

  validates_with *DATA_VALIDTORS, if: :certify
  validates_with *DATE_VALIDATORS, if: :validate_service_date

  scope :signed, -> { where.not(signed_on: nil).order(:signed_on) }
  scope :unsigned, -> { where signed_on: nil}
  scope :listable, -> do
    where.not(cpt_encounter_code: 'TP').or(unsigned.where(cpt_encounter_code: 'TP'))
  end
  scope :treatment_plans, -> { where cpt_encounter_code: 'TP'}
  scope :_90791s, -> { where cpt_encounter_code: '90791' }
  scope :_90853s, -> { where cpt_encounter_code: '90853' }
  scope :testings, -> { where cpt_encounter_code: '96116' }

  SERVICE_DATE_DUPABLE = %w(TP)
  scope :non_dupable, -> { where.not(cpt_encounter_code: SERVICE_DATE_DUPABLE) }

  scope :not_covering, -> { where.not("cpt_encounter_code = '90832' and referral->>'covering' = 'true'") }

  #serialize :encounter_data, HashSerializer
  #store_accessor :encounter_data, :background_history, :certification, :diagnosis, :functional_status, :plan, :problem, :progress, :referral, :therapeutic_communication, :competency, :goals, :group_data

  def self.certification_date_between(sdate, edate)
    query = <<-SQL
      WITH
        existing_scope AS (#{existing_scope_sql}),
        encounters_scoped AS (SELECT enc_encounters.*,
          enc_encounters.certification->>'treatment_plan_date' as sd_utc
            FROM enc_encounters
            INNER JOIN existing_scope ON existing_scope.id = enc_encounters.id)

        SELECT encounters_scoped.* FROM encounters_scoped WHERE sd_utc BETWEEN '#{sdate}' AND '#{edate}'
    SQL

    find_by_sql query
  end

  def self.order_date_between(sdate, edate)
    query = <<-SQL
      WITH
        existing_scope AS (#{existing_scope_sql}),
        encounters_scoped AS (SELECT enc_encounters.*,
          enc_encounters.referral->>'order_date' as sd_utc
            FROM enc_encounters
            INNER JOIN existing_scope ON existing_scope.id = enc_encounters.id)

        SELECT encounters_scoped.* FROM encounters_scoped WHERE sd_utc BETWEEN '#{sdate}' AND '#{edate}'
    SQL

    find_by_sql query
  end

  def self.service_date_between(sdate, edate)
    query = <<-SQL
      WITH
        existing_scope AS (#{existing_scope_sql}),
        encounters_scoped AS (SELECT enc_encounters.*,
          enc_encounters.referral->>'service_date' as sd_utc
            FROM enc_encounters
            INNER JOIN existing_scope ON existing_scope.id = enc_encounters.id)

        SELECT encounters_scoped.* FROM encounters_scoped WHERE sd_utc BETWEEN '#{sdate}' AND '#{edate}'
    SQL

    find_by_sql query
  end

  def self.existing_scope_sql
    self.connection.unprepared_statement {self.reorder(nil).select("id").to_sql}
  end

  def self.filter(user, opts={})
    practice = user.practice || user.meta.practice
    raise StandardError, 'no practice_id' unless practice

    encounters = user.meta.encounters
    providers = practice.providers.where id: opts[:provider_ids]
    signed_opt = Array(opts[:signed]).sort.join
    filter_by_signer = false

    # force reviewers to get only signed notes
    if user.meta_type == "Usr::Reviewer" && user.meta.reviewer_type != "practice"
      opts[:signed] = ['Y']
    end

    # force incident to providers to only see 90791 encounters or those they have already added
    if user.try(:incident_to_provider?)
      encounters = encounters.where('"enc_encounters"."incident_to_provider_id" = ? OR "enc_encounters"."cpt_encounter_code" = ?', user.meta.id, '90791')
    end

    if opts[:patient_ids].present? # force filter by patients
      encounters = encounters.where(patient_id: opts[:patient_ids])
    else # filter by providers/facilities
      if opts[:facility_ids].present?
        facilities = practice.facilities.where(id: opts[:facility_ids])
        encounters = encounters.joins(:patient).where(pat_patients: {
          facility_id: facilities.pluck(:id)
        })
      end

      if providers.any?
        if signed_opt == 'Y'
          filter_by_signer = true
        else
          encounters = encounters.where(signed_by: providers)
        end
      end
    end

    encounters =
      case signed_opt
      when 'Y'
        if filter_by_signer
          encounters.signed.where(signer: providers.pluck(:id))
        else
          encounters.signed
        end
      when 'N'
        encounters.unsigned
      else
        encounters
      end

    if opts[:cpts]
      # special cases for combined codes
      tc_encounter_ids = nil
      tc_service_conducted = []
      tc_cpts = []

      if opts[:cpts].delete('90832')
        tc_service_conducted << '1'
        tc_cpts << '90832'
      end

      if opts[:cpts].delete('90834')
        tc_service_conducted << '2'
        tc_cpts << '90832'
      end

      if opts[:cpts].delete('98966')
        tc_service_conducted << '10'
        tc_cpts << '98966'
      end

      if opts[:cpts].delete('98967')
        tc_service_conducted << '11'
        tc_cpts << '98966'
      end

      if opts[:cpts].delete('98968')
        tc_service_conducted << '12'
        tc_cpts << '98966'
      end

      tc_cpts.uniq!

      if tc_service_conducted.any?
        tc_encounter_ids = encounters.where(cpt_encounter_code: tc_cpts).where("(therapeutic_communication->'service_conducted'->'name')::jsonb ?| array[:cpts]", cpts: tc_service_conducted).pluck(:id)
      end

      if tc_encounter_ids.present?
        encounters = encounters.where(
          'enc_encounters.cpt_encounter_code IN (:cpts) OR enc_encounters.id IN (:encounter_ids)',
          cpts: opts[:cpts],
          encounter_ids: tc_encounter_ids,
        )
      else
        encounters = encounters.where(cpt_encounter_code: opts[:cpts])
      end
    end

    if opts[:primary_insurance_id]
      encounters = encounters.joins(patient: :primary_insurance).where(pat_patients: {primary_insurance_id: opts[:primary_insurance_id]})
    end

    if opts[:secondary_insurance_id]
      encounters = encounters.joins(patient: :secondary_insurance).where(pat_patients: {secondary_insurance_id: opts[:secondary_insurance_id]})
    end

    # lookups for data in singular top level fields of json attributes
    # map of encounter_field => { top_level_field_attribute => opt_field }
    json_name_queries = {
      background_history: {
        birth_place: :background_history_birth_place,
        education_status: :background_history_education_status,
        family_background: :background_history_family_background,
        family_status: :background_history_family_status,
        marital_status: :background_history_marital_status,
        occupational_status: :background_history_occupational_status,
        raised_by: :background_history_raised_by,
        religious_status: :background_history_religious_status,
      },
      diagnosis: {
        primary: :diagnosis_primary,
        prognosis: :diagnosis_progosis,
        secondary: :diagnosis_secondary,
      },
      functional_status: {
        insight: :functional_status_insight,
        intellectual_ability: :functional_status_intability,
        motivation: :functional_status_motivation,
        reasoning: :functional_status_reasoning,
        recall: :functional_status_recall,
        respondtreatment_desc: :functional_status_description,
        severity: :functional_status_severity,
        thought_process: :functional_status_thought_process,
      },
      plan: {
        amount_of_service: :plan_amount_of_service,
        crisis_psychotherapy: :plan_crisis_psychotherapy,
        crisis_recommendations: :plan_crisis_recommendation,
        crisis_risk_assessment: :plan_crisis_risk_assessment,
        duration: :plan_duration,
        frequency: :plan_frequency,
      },
      problem: {
        frequency: :problem_frequency,
        intensity: :problem_intensity,
        onset: :problem_onset,
        staffimpression: :problem_staff_impression,
      },
      progress: {
        cgii: :progress_cgii,
        frequency: :progress_frequency,
        session: :progress_session,
      },
      referral: {
        hiatus_reason: :referral_hiatus_reason,
        md_name: :referral_md_name,
      },
    }

    json_name_queries.each do |attribute, mappings|
      mappings.each do |attr, opt_field|
        if opts[opt_field]
          encounters = encounters.where("#{attribute}->'#{attr}'->>'name' = ?", opts[opt_field])
        end
      end
    end

    if opts[:group_data_interventions_cgii]
      encounters = encounters.where("group_data->'interventions'->'cgii'->>'name' = ?", opts[:group_data_interventions_cgii])
    end

    # lookups for data in singular top level fields of json attributes for multiselect
    # map of encounter_field => { top_level_field_attribute => opt_field }
    json_name_queries = {
      functional_status: {
        interactive_complexity: :functional_status_interactive_complexities,
        severity: :functional_status_severities,
      },
    }

    json_name_queries.each do |attribute, mappings|
      mappings.each do |attr, opt_field|
        if opts[opt_field]
          encounters = encounters.where("(#{attribute}->'#{attr}'->'name')::jsonb ?| array[:opt_value]", opt_value: opts[opt_field])
        end
      end
    end

    if opts[:signed_from] || opts[:signed_to]
      opts[:signed_from] ||= '1970-01-01'
      opts[:signed_to] ||= Date.tomorrow.to_s

      from = opts[:signed_from]
      to = opts[:signed_to]

      if !opts[:use_raw_date]
        from = Date.parse(from)
        to = Date.parse(to) + 1
      end

      encounters = encounters.where(signed_on: (from..to))
    end

    if opts[:from] || opts[:to]
      opts[:from] ||= '1970-01-01'
      opts[:to] ||= Date.tomorrow.to_s

      from = opts[:from]
      to = opts[:to]

      if !opts[:use_raw_date]
        from = Date.parse(from)
        to = Date.parse(to) + 1
      end

      enc_ids = encounters.service_date_between(from, to).pluck(:id)
      encounters = encounters.where(id: enc_ids)
    end

    if opts[:md_order_date_from] || opts[:md_order_date_to]
      opts[:md_order_date_from] ||= Time.at(0).utc.to_date.to_s
      opts[:md_order_date_to] ||= Date.tomorrow.to_s

      from = Time.parse(opts[:md_order_date_from])
      to = Time.parse(opts[:md_order_date_to]) + 1

      enc_ids = encounters.order_date_between(from, to).pluck(:id)
      encounters = encounters.where(id: enc_ids)
    end

    if opts[:certification_from] || opts[:certification_to]
      opts[:certification_from] ||= Time.at(0).utc.to_date.to_s
      opts[:certification_to] ||= Date.tomorrow.to_s

      from = Time.parse(opts[:certification_from])
      to = Time.parse(opts[:certification_to]) + 1

      enc_ids = encounters.certification_date_between(from, to).pluck(:id)
      encounters = encounters.where(id: enc_ids)
    end

    # can't filter these in psql?

    # lookups for data in multi-value top level fields of json attributes for multiselects
    # map of encounter_field => { top_level_field_attribute => opt_field }
    json_name_queries = {
      background_history: {
        hist_mental_ill: :background_history_mental_illnesses,
      },
      plan: {
        crisis_mobilization: :plan_crisis_mobilizations,
        other_services: :plan_other_services,
      },
      problem: {
        major_target_symptom: :problem_major_target_symptoms,
        other: :problem_others,
        precipstressors: :problem_precipitating_stressors,
        tp_interventions: :problem_tp_interventions,
      },
      progress: {
        monitoring_mechanisms: :progress_monitoring_mechanisms,
      },
      referral: {
        initiator: :referral_initiator,
        medical_necessity: :referral_medical_necessities,
        reasons: :referral_reasons,
      },
      therapeutic_communication: {
        modalities: :therapeutic_communication_modalities,
        therapy_attempted_to: :therapeutic_communication_attempted_tos,
      },
    }

    enc_ids = nil
    json_name_queries.each do |attribute, mappings|
      mappings.each do |attr, opt_field|
        if opts[opt_field]
          enc_ids ||= encounters.pluck(:id)
          filtered_ids = encounters.find_all do |enc|
            attr_value = enc[attribute][attr]
            if attr_value
              attr_value = [attr_value] if !attr_value.is_a?(Array)
              attr_value.any?{ |data| opts[opt_field].include?(data['name']) }
           end
          end.pluck(:id)

          enc_ids &= filtered_ids
        end
      end
    end

    if opts[:group_data_interventions_therapeutic_factors]
      filtered_ids = encounters.find_all do |enc|
        enc_ids ||= encounters.pluck(:id)
        attr_value = enc.group_data && enc.group_data['interventions'] && enc.group_data['interventions']['therapeutic_factors']
        if attr_value
          attr_value = [attr_value] if !attr_value.is_a?(Array)
          attr_value.any?{ |data| opts[:group_data_interventions_therapeutic_factors].include?(data['name']) }
        end
      end.pluck(:id)

      enc_ids &= filtered_ids
    end

    if opts[:tp_methods_methods]
      filtered_ids = encounters.find_all do |enc|
        enc_ids ||= encounters.pluck(:id)
        attr_value = enc.tp_methods && enc.tp_methods['methods']
        if attr_value
          attr_value = [attr_value] if !attr_value.is_a?(Array)
          attr_value.any?{ |data| opts[:tp_methods_methods].include?(data['name']) }
        end
      end.pluck(:id)

      enc_ids &= filtered_ids
    end

    if enc_ids
      encounters = encounters.where(id: enc_ids)
    end

    encounters
  end

  def data_fields
    Hashie::Mash.new(Hash[DATA_FIELDS.map{|f| [f, send(f)] }])
  end

  def plan_recommended?
    service = plan.amount_of_service
    service && service['name'] != '4'
  end

  def service_date
    date = referral.try(:service_date)

    Date.parse date if date
  end

  def localized_service_date(tz="US/Eastern")
    service_date.in_time_zone(tz).to_date
  end

  def start_time
    time = certification.start_time
    Time.parse(time).strftime "%I:%M %p"
  end

  def end_time
    time = certification.end_time
    Time.parse(time).strftime "%I:%M %p"
  end

  def encounter_type(with_modifier=false, with_ic=false)
    case cpt_encounter_code
    when "TP"
      "Treatment Plan"
    when 'GBH1'
      'G0323'
    when "90832"
      service = ref_val('therapeutic_communication.service_conducted')
      return "90832" unless service
      code = service[/\((.*)\)/, 1]
      return service unless code # psych untimed

      codes = code.split(',')
      codes = add_modifier(with_modifier, codes) {|cc|
        cc.map! {|c| [c, code_modifier].join('-') }
      }
      with_ic ? codes.join(',') : codes.first
    when '98966'
      case therapeutic_communication&.[]('service_conducted')&.[]('name')
        when '10' then '98966'
        when '11' then '98967'
        when '12' then '98968'
        else cpt_encounter_code
      end
    when '96116'
      add_modifier(with_modifier, referral.code) {|c| [c, code_modifier].join('-') }
    else
      add_modifier(with_modifier, cpt_encounter_code) {|c| [c, code_modifier].join('-') }
    end
  end

  def add_modifier(domod=false, code)
    return code unless domod and has_modifier?
    yield code
  end

  def family_therapy?
    !!therapeutic_communication.try(:service_conducted).try(:name).in?(%w(8 9))
  end

  def pdfname
    export_name << '.pdf'
  end

  def docxname
    export_name << '.docx'
  end

  def reimbursement_rate
    providers = patient.insurance.map{|ins_tier| ins_tier.last.insurer}.compact.map(&:type_name).compact

    rater = ::Enc::Rate.rates[encounter_type.to_s]
    return 0 unless rater

    rater.run providers
  end

  def signed?
    signed_on and signed_by
  end

  def build_hp_xml
    Enc::HpXmlBuilder.build self
  end

  def build_claim_md_xml
    Enc::ClaimMdXmlBuilder.build self
  end

  def build_claim_md_xml!(builder=nil)
    (builder or build_claim_md_xml).tap do |xml|
      xml = xml.to_xml

      shipped = OpenStruct.new(
        xml: xml,
      )
      if block_given?
        yield shipped
      end

      update! shipped_hp_billing: shipped.to_h
    end
  end

  def build_hp_xml!(builder=nil)
    (builder or build_hp_xml).tap do |xml|
      {
        nil => :to_xml,
        'secondary' => (has_interactive_complexity? or has_90840?) ? :to_secondary_xml : nil,
      }.each do |prefix, to_xml|
        next unless to_xml

        shipped = OpenStruct.new(shipped_hp_billing)
        fname = lambda{|name| [prefix, name].compact*'_' }
        fields = OpenStruct.new(filename: fname['filename'], xml: fname['xml'])

        next if [shipped[fields.filename], shipped[fields.xml]].all?(&:present?)
        shipped[fields.filename] = "#{signer.hp_code}-#{Time.now.to_f}.xml"
        shipped[fields.xml] = xml.send(to_xml)

        if block_given?
          yield OpenStruct.new(
            filename: shipped[fields.filename],
            xml: shipped[fields.xml]
          )
        end

        update! shipped_hp_billing: shipped.to_h
      end
    end
  end

  def shipped_to_claim_md?
    shipped_hp_billing.present? && shipped_hp_billing['xml'].present?
  end

  def shipped_to_hp?
    hp_keys = [[:filename, [:xml, :s3]]]

    if has_90840? or has_interactive_complexity?
      hp_keys << [:secondary_filename, [:secondary_xml, :secondary_s3]]
    end

    hp_keys.all? do |k1, k2|
      !!shipped_hp_billing[k1] and k2.any?{|k| !!shipped_hp_billing[k] }
    end
  end

  def charge_units
    1
  end

  def referring_dr
    return " " unless cpt_encounter_code == "96116" && signer.respond_to?(:hp_code)

    signer.hp_code
  end

  def valid_for_charge?
    unbilled_notes = ["treatment plan", "psychotherapy untimed"]

    patient                                             &&
      patient.facility                                  &&
      patient.dob.respond_to?(:to_date)                 &&
      signer                                            &&
      patient.insurance.primary.insurer                 &&
      patient.insurance.primary.number                  &&
      !encounter_type.to_s.downcase.in?(unbilled_notes) &&
      diagnosis.try(:primary).try(:name)                &&
      billable?
  end

  def group_billable?
    return true unless cpt_encounter_code == '90853'
    return false unless (primary=patient.primary_insurance)

    duration = session_duration
    participants = group_data.session.try(:participants) || 0
    if primary.medicaid?
      duration >= 90 && participants <= 8
    elsif primary.medicare? || primary.medicare_hmo?
      duration >= 45 && participants <= 12
    else
      true
    end
  end

  # Placeholder for when we add #unbilled? flag
  def billable?
    return false if cpt_encounter_code == 'TP' # "TPs are not billable at all"

    if cpt_encounter_code == '90791'
      !unbilled? && group_billable?
    else
      group_billable?
    end
  end

  def has_interactive_complexity?
    return false if cpt_encounter_code == '90839'
    functional_status.try(:interactive_complexity).try(:name) == 'Y'
  end

  def has_90840?
    return false unless cpt_encounter_code == '90839'
    return false unless plan.try(:crisis_additional_time).try(:name) == 'Y'
    plan.try(:crisis_additional_time_minutes).try(:name) == 'more'
  end

  # in minutes
  def session_duration
    return unless signed?
    stime = certification.start_time.to_time
    etime = certification.end_time.to_time
    (etime - stime) / 60
  rescue
    # TODO how to handle this case?
    # should never happen but still..
    0
  end

  def referral_has_plan?
    plan.present? && referral && referral.reasons.find {|r| r.try(:name) == '1' }
  end

  def referral_has_competency?
    competency.present? && referral && referral.reasons.find {|r| r.try(:name) == '2' }
  end

  def has_short_cert?
    return true if cpt_encounter_code == '90839'
    cpt_encounter_code == '90791' &&
      (referral_has_plan? && plan.amount_of_service.try(:name) == '4') ||
      referral_has_competency?
  end

  def has_long_cert?
    return true if cpt_encounter_code == '90832'

    cpt_encounter_code == '90791' &&
      referral_has_plan? &&
      plan.amount_of_service.try(:name) != '4'
  end

  def cert_phrasings
    certs =
      case cpt_encounter_code
      when '90791'
        %i(short long).map {|i| i if send(:"has_#{i}_cert?")}.compact
      when '90839'
        :short
      when '90832'
        :long
      when '90853'
        :group
      when 'TP', 'GBH1'
        :tp
    end

    CERTS.values_at(*certs)
  end

  FAMILY_THERAPY_CODES = %w(90846 90847)
  def family_therapy?
    encounter_type.in? FAMILY_THERAPY_CODES
  end

  def follow_up_header(include_incident_to = false)
    if cpt_encounter_code == '98966'
      return "Telephone assessment and management service (#{encounter_type})"
    end

    return nil unless cpt_encounter_code == '90832'

    header = ref_val('therapeutic_communication.service_conducted')
    return '90832' unless header

    incident_to = nil
    if include_incident_to && incident_to_provider_id.present?
      incident_to = '-"Incident to"'
    end
    header.to_s.upcase.sub /\(.*\)/, "(#{encounter_type(true, true)}#{incident_to})"
  end

  def lookup(path)
    path.split('.').inject(self) do |enc, key|
      enc[key]
    end.try(:name)
  end

  def ref_val(path)
    key = lookup(path)
    Ref::Lookup.encounters.lookup path, key
  end

  def alt_pos?
    (facility_pos_code || patient.facility_pos_code) == ::Pat::Patient::ALT_POS_CODE
  end

  def testing_header
    return unless cpt_encounter_code.to_i == 96116

    case referral.code.to_i
    when 96116
      'Neurobehavioral Status Exam'
    when 96130
      "Psychological testing evaluation services"
    when 96132
      "Neurobehavioral status exam"
    end
  end

  def testing_header_with_code
    [ referral.code, testing_header ] * " - "
  end

  def testing_service_dates
    (2..4).map {|n| referral["service_date#{n}"] }.
      unshift(referral.service_date).
      compact.
      map(&:to_date).
      sort.
      map {|d| d.strftime("%m/%d/%Y")}
  end

  private

  def modifierable?
    cpt_encounter_code.in?(MODIFIERABLE_CODES)
  end

  def has_modifier?
    !code_modifier.blank?
  end

  def assign_95_modifier
    return false unless errors.blank?
    return if facility_pos_code != 95

    self.code_modifier = 95
  end

  def assign_59_modifier
    return false unless errors.blank?
    other_code = family_therapy? ? '90832' : '90846'

    dups = Enc::ServiceDateDupCheck.run(patient.id, other_code, service_date)
    existing = dups.result.select {|e| e.cpt_encounter_code == '90832'}.find do |e|
      if other_code == '90832'
        !e.family_therapy?
      else
        e.family_therapy?
      end
    end

    if existing
      self.code_modifier = 59
      existing.code_modifier = 59
      existing.save(validate: false) # no validations so we skip this callback
    end

    # Add -59 modifier for group therapy notes
    #
    # :service_date_between returns an array so need to switch
    # back to a rails collection
    note_ids = patient.encounters.signed.
      where(cpt_encounter_code: cpt_encounter_code == '90853' ? '90832' : '90853').
      service_date_between(service_date, service_date.tomorrow).
      pluck(:id)

    unless note_ids.blank?
      Enc::Encounter.where(id: note_ids).update_all(code_modifier: 59)
      self.code_modifier = 59
    end

    #something like...
    # e=Enc::ServiceDateDupCheck.run(patient.id, '90832', service_date, id)
    # if e.results.find {|e| e.cpt_encounter_code == '90832'}
    #   self.has_code_modifier = true
    #   self.code_modifier = 59 
    # end
  end

  def export_name
    date = service_date
    date &&= date.strftime('%Y%m%d')
    [id, cpt_encounter_code, date].join("-")
  end

  # def extract(value)
  #   return unless encounter_data
  #
  #   first, *keys = value.split('.')
  #   val = encounter_data[first]
  #   return nil unless val
  #
  #   keys.each do |key|
  #     if val[key]
  #       val = val[key]
  #     end
  #   end
  #
  #   val
  # end

  def reject_screenings(attrs)
    attrs['screening_type'].blank? or
      !attrs['screening_type'].in?(Enc::Screening.screening_types.keys)
  end

  def changed_attributes
    detected_changes = super
    false_positives = []

    detected_changes.each do |field, old_val|
      next unless DATA_FIELDS.include?(field.to_sym)
      next if [send(field), old_val].map(&:to_json).uniq.size > 1
      false_positives << field
    end

    false_positives.blank? ?
      detected_changes : detected_changes.except(*false_positives)
  end

  def dedup_screenings
    new_screens = screenings.select(&:new_record?)
    if new_screens.any?
      orig = screenings.to_a.clone
      new_screens.each do |screen|
        if existing = screenings.where(screening_type: screen.screening_type).first
          orig.find {|o| o.id == existing.id}.axes = screen.axes
          orig.reject! {|s| s.new_record? && s.screening_type == screen.screening_type}
        end
      end
      self.screenings = orig
    end
  end

  def update_patient_pos
    return unless signed?
    return unless facility_pos_code.in?(Pat::Patient::FAC_POS_CODES)
    return if patient.facility_pos_code == facility_pos_code

    latest = patient.encounters.signed.reorder("referral->>'service_date' DESC").where.not(id: id).first
    return if latest &&
      latest.facility_pos_code.in?(Pat::Patient::FAC_POS_CODES) &&
      latest.service_date > service_date

    patient.update facility_pos_code: facility_pos_code
  end
end

