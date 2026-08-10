class Grp::NoteSubject < ApplicationRecord
  audited

  belongs_to :patient_note, class_name: 'Grp::PatientNote'
  belongs_to :patient, class_name: 'Pat::Patient'
end
