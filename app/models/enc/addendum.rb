class Enc::Addendum < ApplicationRecord
  audited

  belongs_to :encounter
  belongs_to :user, class_name: 'Usr::User'
end
