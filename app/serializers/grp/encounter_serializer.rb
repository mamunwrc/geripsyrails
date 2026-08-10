class Grp::EncounterSerializer < ActiveModel::Serializer
  attributes :id, :group_id, :group_therapy_session, :interventions, :certification
  belongs_to :group
  belongs_to :signer

  attribute :certified do
    object.signed?
  end

  attribute :patient_count do
    object.session_patients.count
  end

  attribute :patient_notes do
    object.patient_notes.map do |note|
      {
        id: note.id,
        body: note.body,
        names: note.patients.map(&:full_name),
        patients: note.patients.select(:id, :first_name, :last_name)
      }
    end
  end
end
