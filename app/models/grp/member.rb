class Grp::Member < ApplicationRecord
  audited

  belongs_to :group, class_name: 'Grp::Group'
  belongs_to :patient, class_name: 'Pat::Patient'
end
