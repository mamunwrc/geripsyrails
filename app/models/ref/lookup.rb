class Ref::Lookup < ApplicationRecord
  validates :keyprefix, presence: true, length: {maximum: 32}
  validates :keyname, presence: true, length: {maximum: 32}
  validates :keyvalue, presence: true
  validates :group, presence: true

  scope :encounters, -> { where(group: 'encounters') }
  scope :main, -> { where(group: 'main') }

  include Ref::LookupMap::Mixin

  default_lookup_group :encounters

  lookup_query do |l|
    where(keyprefix: l.prefix, keyname: l.name)
  end

  create_mapping do |group|
    group.branch :therapeutic_communication do |map|
      map.service_conducted = "SERVICECONDUCTED"
    end
  end
end

