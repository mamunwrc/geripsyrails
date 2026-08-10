class Usr::Reviewer < ApplicationRecord
  audited

  has_one :user, as: :meta, dependent: :destroy
  accepts_nested_attributes_for :user

  belongs_to :practice, class_name: 'Adm::Practice'
  has_many :patients, through: :practice, class_name: 'Pat::Patient'

  enum reviewer_type: %i(practice facility patient provider), _prefix: true

  def permitted_patients
    case reviewer_type.to_sym
    when :practice
      patients
    when :facility
      patients.where facility_id: associated_facilities
    when :patient
      patients.where id: associated_patients
    when :provider
      patients.joins(:providers).where "patients_providers.provider_id in (?)", associated_providers
    end
  end

  def encounters
    case reviewer_type.to_sym
    when :practice
      practice.encounters
    when :facility
      Enc::Encounter.joins(:patient).where(pat_patients: { facility_id: associated_facilities })
    when :provider
      Enc::Encounter.joins(:providers).where(patients_providers: { provider_id: associated_providers } )
    end
  end

  def facilities
    return practice.facilities if reviewer_type == "practice"
    return [] unless reviewer_type == "facility"
    practice.facilities.where id: associated_facilities
  end

  def providers
    case reviewer_type.to_sym
    when :practice, :facility
      practice.providers
    when :provider
      practice.providers.where id: associated_providers
    else
      []
    end
  end
end

