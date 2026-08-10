class Enc::HpXmlBuilder
  def self.build(encounter)
    new(encounter).tap(&:build!)
  end

  def initialize(encounter)
    @encounter = encounter
    @xml = Nokogiri::XML::Builder.new
  end

  attr_reader :encounter, :xml

  def build!
    raise Enc::Encounter::NotValidForChargeError unless encounter.valid_for_charge?
    raise Enc::Encounter::AlreadyShippedToHpError if encounter.shipped_to_hp?
    return if @xml_built

    pat = encounter.patient
    facility = pat.facility

    @xml.encounter do |x|
      x.patient_code pat.id
      x.patient_first_name pat.first_name
      x.patient_last_name pat.last_name
      x.patient_dob pat.dob.to_date
      x.patient_gender pat.gender
      x.patient_ssn pat.ssn
      x.patient_address1 facility.address1
      x.patient_address2 facility.address2
      x.patient_city facility.city
      x.patient_state facility.state
      x.patient_zip facility.zip
      x.patient_phone facility.work_phone

      ins = pat.insurance
      tiers = %i(primary secondary tertiary)

      # only send primary if primary is medicare_hmo or medicaid
      if ins.primary.insurer.try(:medicaid?)
        tiers = tiers[0..0]
      elsif ins.primary.insurer.try(:medicare_hmo?) || (ins.primary.insurer.try(:medicare?) && ins.secondary.insurer.try(:medicaid?))
        tiers = tiers[0..1]
      end

      tiers.each do |ins_type|
        add_tier x, ins_type, pat.insurance[ins_type]
      end

      # add empty nodes for other insurance tiers if necessary
      tiers = tiers.size == 1 ? %w(secondary tertiary) :
        (tiers.size == 2 ? %w(tertiary) : [])
      tiers.each {|tier| add_tier(x, tier, OpenStruct.new)}

      x.facility facility.hp_code_for(encounter)
      x.signer encounter.signer.hp_code
      x.cpt_code encounter.encounter_type(true)
      x.icd10 encounter.diagnosis.primary.name

      x.service_date encounter.service_date
      x.charge_units encounter.charge_units
      x.referring_dr encounter.referring_dr
    end

    if encounter.has_90840?
      @secondary_xml = @xml.doc.deep_dup
      @secondary_xml.at('cpt_code').content = '90840'
    elsif encounter.has_interactive_complexity?
      @secondary_xml = @xml.doc.deep_dup
      @secondary_xml.at('cpt_code').content = "90785"
    end

    @xml_built = true
  end

  def to_xml
    @xml.to_xml
  end

  def to_secondary_xml
    return unless @secondary_xml
    @secondary_xml.to_xml
  end

  private

  def add_tier(xml, type, tier)
    # HP spec requires all expected nodes be sent even if they are nil
    vals =
      if tier.insurer && tier.number
        {code: tier.insurer.hp_code, name: tier.insurer.name, number: tier.number}
      else
        {}
      end

    xml.send "#{type}_ins_code", vals[:code]
    xml.send "#{type}_ins_name", vals[:name]
    xml.send "#{type}_ins_id", vals[:number]
  end
end
