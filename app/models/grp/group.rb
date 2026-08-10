class Grp::Group < ApplicationRecord
  audited

  has_many :leaders, dependent: :destroy
  has_many :members, dependent: :destroy
  has_many :providers, through: :leaders, before_add: :assert_same_practice!
  has_many :patients, through: :members
  has_many :encounters, class_name: 'Grp::Encounter'

  has_one :unsigned_encounter, -> { unsigned }, class_name: 'Grp::Encounter'

  belongs_to :practice, class_name: 'Adm::Practice', required: true

  attr_accessor :incoming_patient_ids

  before_save :update_patients

  validates :name, presence: true

  def create_encounter!
    return unsigned_encounter if unsigned_encounter

    if previous = encounters.signed.ordered_by_service_date.last
      session = previous.group_therapy_session.deep_dup
      interventions = previous.interventions.deep_dup

      session.service_date = Date.today
      session.delete(:service_date_raw)

      # Remove previous session patients that
      # have been removed from group
      (session.patients || []).reject! {|pat| !pat.name.in?(patient_ids) }

      # These fields must change session to session
      # Keeping the previous data to display to provider
      session.goal_prev = session.delete(:goal)
      interventions.dynamics_prev = interventions.delete(:dynamics)
      interventions.description_prev = interventions.delete(:description)

      encounters.create({
        group_therapy_session: session,
        interventions: interventions
      })
    else
      encounters.create( group_therapy_session: { service_date: Date.today } )
    end
  end

  private

  def update_patients
    if Array(incoming_patient_ids).present?
      ids = (providers.map(&:patient_ids).flatten & incoming_patient_ids)
      self.patients = Pat::Patient.where(id: ids, has90791: true)

      # update unsigned note patient list
      # and trash notes associated with non group members
      if enc = unsigned_encounter
        (enc.group_therapy_session.patients || []).reject! do |pat|
          !pat.name.in?(ids)
        end
        enc.save!
      end
    end
  end

  def assert_same_practice!(provider)
    raise ActiveRecord::RecordNotSaved, 'practice_ids do not match' unless
      practice_id == provider.practice_id
  end
end
