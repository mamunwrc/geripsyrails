class Grp::Addendum < ApplicationRecord
  belongs_to :encounter
  belongs_to :user, class_name: 'Usr::User'

  after_create :copy_to_session_notes

  private

  def copy_to_session_notes
    if encounter.signed? && encounter.session_encounters.present?
      encounter.session_encounters.each do |enc|
        enc.addendum = note
        enc.addendum_user_id = user_id
        enc.save!
      end
    end
  end
end
