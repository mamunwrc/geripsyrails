class Enc::ClaimMdXmlBuilder
  def self.build(encounter)
    new(encounter).tap(&:build!)
  end

  def initialize(encounter)
    @encounter = encounter
    @builder = Nokogiri::XML::Builder.new
  end

  attr_reader :encounter, :builder

  def build!
    # raise Enc::Encounter::NotValidForChargeError unless encounter.valid_for_charge?
    # raise Enc::Encounter::AlreadyShippedToHpError if encounter.shipped_to_claim_md?
    return if @xml_built

    builder.claim(claim_attrs) do |xml|
      xml.charge(charge_attrs)

      secondary = secondary_charge_attrs
      xml.charge(secondary) if secondary
    end

    @xml_built = true
  end

  def to_xml
    # exclude xml version info
    builder.doc.root.to_xml
  end

  private

  def claim_attrs
    # pat_country should be 2-letter code, blank if US
    facility_country = facility.country
    country = Country.find_country_by_name(facility_country) || Country.find_country_by_name(facility_country)
    facility_country = country&.alpha2
    facility_country = nil if facility_country == 'US'

    payerid = patient.primary_insurance&.payerid
    other_payerid = patient.secondary_insurance&.payerid

    {
      accept_assign: 'Y',
      amount_paid: nil,
      auto_accident: 'N',
      auto_accident_state: '',
      bill_addr_1: provider_user.address1,
      bill_addr_2: provider_user.address2,
      bill_city: provider_user.city,
      bill_id: nil,
      bill_name: provider_user.full_name,
      bill_npi: provider.npi,
      bill_phone: provider_user.work_phone || provider_user.home_phone,
      bill_state: provider_user.state,
      bill_taxid: provider.tax_number,
      bill_taxid_type: 'E', # E = EIN, S = SSN
      bill_taxonomy: nil,
      bill_zip: provider_user.zip,
      clia_number: nil,
      diag_1: encounter.diagnosis.primary.name,
      diag_1_poa: nil,
      diag_2: nil,
      diag_2_poa: nil,
      diag_3: nil,
      diag_3_poa: nil,
      diag_4: nil,
      diag_4_poa: nil,
      diag_5: nil,
      diag_5_poa: nil,
      diag_6: nil,
      diag_6_poa: nil,
      diag_7: nil,
      diag_7_poa: nil,
      diag_8: nil,
      diag_8_poa: nil,
      diag_9: nil,
      diag_9_poa: nil,
      diag_10: nil,
      diag_10_poa: nil,
      diag_11: nil,
      diag_11_poa: nil,
      diag_12: nil,
      diag_12_poa: nil,
      diag_13: nil,
      diag_13_poa: nil,
      diag_14: nil,
      diag_14_poa: nil,
      diag_15: nil,
      diag_15_poa: nil,
      diag_16: nil,
      diag_16_poa: nil,
      diag_17: nil,
      diag_17_poa: nil,
      diag_18: nil,
      diag_18_poa: nil,
      diag_19: nil,
      diag_19_poa: nil,
      diag_20: nil,
      diag_20_poa: nil,
      diag_21: nil,
      diag_21_poa: nil,
      diag_22: nil,
      diag_22_poa: nil,
      diag_23: nil,
      diag_23_poa: nil,
      diag_24: nil,
      diag_24_poa: nil,
      employment_related: nil,
      facility_addr_1: facility.address1,
      facility_addr_2: facility.address2,
      facility_city: facility.city,
      facility_id: nil,
      facility_name: facility.name,
      facility_npi: facility.npi,
      facility_state: facility.state,
      facility_zip: facility.zip,
      hosp_from_date: nil,
      hosp_thru_date: nil,
      icn_dcn_1: nil,
      ins_addr_1: nil,
      ins_addr_2: nil,
      ins_city: nil,
      ins_country: nil,
      ins_dob: nil,
      ins_employer: nil,
      ins_group: nil,
      ins_name_f: patient.first_name,
      ins_name_l: patient.last_name,
      ins_name_m: patient.middle_name,
      ins_number: patient.primary_insurance_number,
      ins_phone: nil,
      ins_plan: nil,
      ins_sex: nil,
      ins_state: nil,
      ins_zip: nil,
      narrative: nil,
      ord_prov_name_f: nil,
      ord_prov_name_l: nil,
      ord_prov_name_m: nil,
      ord_prov_npi: nil,
      other_ins_dob: nil,
      other_ins_group: nil,
      other_ins_medicare_code: nil,
      other_ins_name_f: patient.secondary_insurance_number && patient.first_name,
      other_ins_name_l: patient.secondary_insurance_number && patient.last_name,
      other_ins_name_m: patient.secondary_insurance_number && patient.middle_name,
      other_ins_number: patient.secondary_insurance_number,
      other_ins_payment_date: nil,
      other_ins_plan: nil,
      other_ins_sex: nil,
      other_pat_rel: nil,
      other_payer_addr_1: nil,
      other_payer_addr_2: nil,
      other_payer_city: nil,
      other_payer_name: patient.secondary_insurance_number && patient.secondary_insurance&.name,
      other_payer_phone: nil,
      other_payer_state: nil,
      other_payer_typecode: nil,
      other_payer_zip: nil,
      other_payerid: other_payerid,
      pat_addr_1: facility.address1,
      pat_addr_2: facility.address2,
      pat_city: facility.city,
      pat_country: facility_country,
      pat_dob: formatted_date(patient.dob),
      pat_name_f: patient.first_name,
      pat_name_l: patient.last_name,
      pat_name_m: patient.middle_name,
      pat_phone: facility.work_phone,
      pat_rel: 18, # SELF
      pat_sex: formatted_gender(patient.gender),
      pat_ssn: nil,
      pat_state: facility.state,
      pat_zip: facility.zip,
      pay_addr_1: nil,
      pay_addr_2: nil,
      pay_city: nil,
      pay_state: nil,
      pay_zip: nil,
      payer_addr_1: patient.primary_insurance&.address1,
      payer_addr_2: patient.primary_insurance&.address2,
      payer_city: patient.primary_insurance&.city,
      payer_name: nil,
      payer_order: nil,
      payer_state: patient.primary_insurance&.state,
      payer_zip: patient.primary_insurance&.zip,
      payerid: payerid,
      pcn: patient.id,
      prior_auth: patient.prior_authorization_number,
      prov_id: nil,
      prov_name_f: nil,
      prov_name_l: nil,
      prov_name_m: nil,
      prov_npi: nil,
      prov_taxid: nil,
      prov_taxid_type: nil,
      prov_taxonomy: nil,
      ref_id: nil,
      ref_name_f: nil,
      ref_name_l: nil,
      ref_name_m: nil,
      ref_npi: nil,
      remote_batchid: nil,
      remote_claimid: nil,
      remote_fileid: nil,
      total_charge: total_charge,
    }
  end

  def total_charge
    total = BigDecimal(charge_attrs[:charge])

    secondary = secondary_charge_attrs
    if secondary
      total += BigDecimal(secondary[:charge])
    end

    total.to_s
  end

  def charge_attrs(proc_code = encounter.encounter_type(true), cpt_code = encounter.encounter_type)
    # "95" is used for coding telehealth services, but as a modifier, not as a POS
    pos_code = encounter.facility_pos_code
    mod1 = nil
    if pos_code == 95
      pos_code = patient.facility_pos_code
      mod1 = 95
    end

    {
      charge: charge(cpt_code),
      diag_ref: 'A',
      from_date: formatted_date(encounter.service_date),
      mod1: mod1,
      mod2: nil,
      mod3: nil,
      mod4: nil,
      narrative: nil,
      ndc_code: nil,
      ndc_dosage: nil,
      ndc_measure: nil,
      ndc_price: nil,
      place_of_service: pos_code,
      proc_code: proc_code,
      remote_chgid: nil,
      thru_date: nil,
      units: units,
    }
  end

  def secondary_charge_attrs
    if encounter.has_90840?
      return charge_attrs('90840', '90840')
    elsif encounter.has_interactive_complexity?
      return charge_attrs('90785', '90785')
    end

    nil
  end

  def charge(cpt_code)
    Adm::CptPrice.where(cpt_code: cpt_code).first&.price&.to_s
  end

  def charge_units(mins, base=60, leftover=31)
    units, mod = mins.divmod(base)
    units += 1 if mod >= leftover
    units = 1 if units.zero?
    units.to_s
  end

  def units
    return '1' if encounter.certification.blank? || encounter.end_time.blank? || encounter.start_time.blank?

    minutes = (Time.parse(encounter.certification.end_time) - Time.parse(encounter.certification.start_time)) / 60
    units = nil

    units = charge_units(minutes - 60) if minutes > 90

    units = '1' if units.to_i == 0 || units.blank?

    units
  end

  def facility
    patient.facility
  end

  def insurance
    patient.insurance
  end

  def patient
    encounter.patient
  end

  def provider
    if encounter.signer.incident_to_provider?
      encounter.signer.linked_provider
    else
      encounter.signer
    end
  end

  def provider_user
    provider.user
  end

  def formatted_date(date)
    date.strftime('%Y-%m-%d')
  end

  def formatted_gender(gender)
    gender.to_s[0]&.upcase
  end

end
