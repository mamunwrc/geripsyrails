class Pat::PatientSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :dob, :has90791, :ssn, :insurance_data, :providers, :notes, :room_num, :primary_insurance_number, :secondary_insurance_number, :tertiary_insurance_number, :primary_provider_id, :facility_pos_code, :testing_provider_id, :prior_authorization_number, :incident_to_provider_id
  attribute(:full_name) { [object.first_name, object.last_name].join " " }
  attribute(:facility_id) { { val: object.facility.try(:name), name: object.facility_id } }
  attribute(:primary_provider_id) { { val: object.primary_provider.try(:full_name), name: object.primary_provider_id } }
  attribute(:testing_provider_id) do
    if object.testing_provider_id.to_i.zero?
      {
        val: 'None',
        name: 0
      }
    else
      pro = Usr::Provider.find(object.testing_provider_id)
      {
        val: pro.full_name,
        name: pro.id
      }
    end
  end
  attribute(:gender) { { val: object.gender, name: object.gender } }
  attribute(:status) { { val: object.status, name: object.status } }

  # NOTE
  #
  # This node can and should be removed now
  # BUT TRIPLE CHECK FIRST!!!!
  attribute(:insurers) do
    # rm medicare from list
    # handling based on facility location
    ins = Pat::Insurance.not_medicare
    ins.to_a.
      unshift(Hashie::Mash.new name: 'Medicare', hp_id_code: ::Pat::Insurance::MEDICARE_GLOBAL_ID).
      push(Hashie::Mash.new name: 'PROVIDER NOT LISTED', hp_id_code: ::Pat::Insurance::OTHER_INSURANCE_ID)
  end

  %i(primary_insurance_id secondary_insurance_id tertiary_insurance_id).each do |insid_field|
    attribute insid_field do
      insval = object.send(insid_field)
      if insval.in?(::Pat::Insurance::MEDICARE_IDS)
        ::Pat::Insurance::MEDICARE_GLOBAL_ID
      else
        insval
      end
    end
  end

  attribute :treatment_plan do
    plans = object.treatment_plans.select(:id, :referral)
    resp = {
      initial: {},
      latest: {},
      exists: !plans.blank?,
      all: plans.pluck(:id, :referral).map {|p|
        {
          id: p[0],
          date: p[1].try(:service_date)
        }
      }
    }

    unless plans.blank?
      resp[:initial] = {
        id: plans.first.id,
        date: plans.first.referral.try(:service_date)
      }
      resp[:latest] = {
        id: plans.last.id,
        date: plans.last.referral.try(:service_date)
      }
    end

    resp
  end

  attribute(:needs_tp) { object.needs_tp? }

  belongs_to :facility
  #has_many :screenings
  attribute(:screenings) do
    object.screenings.select('distinct on (screening_type, encounter_id) enc_screenings.id, axes, screening_type, encounter_id, enc_screenings.created_at')
  end

  def providers
    object.providers.map do |provider|
      {
        id: provider.id,
        full_name: provider.full_name,
        degree: provider.degree
      }
    end
  end

  def notes
    object.notes.includes([:user]).map do |note|
      {
        writer: note.user.full_name,
        text: note.text,
        date: note.created_at,
      }
    end
  end
end
