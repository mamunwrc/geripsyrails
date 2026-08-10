class Grp::Leader < ApplicationRecord
  audited

  belongs_to :group, class_name: 'Grp::Group'
  belongs_to :provider, class_name: 'Usr::Provider'
end
