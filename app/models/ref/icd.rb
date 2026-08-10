class Ref::Icd < ApplicationRecord
  validates :icd, uniqueness: {scope: :group}

  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :sorted_actives, -> do
    select(:icd, :description, :is_common).
      from(
        select('DISTINCT ON (icd) *').
          where(is_active: true).
          order(:icd)
      ).order('is_common desc, description')
  end

  # Import a group of codes with option to reseed group from scratch
  def self.import(group, codes, rm=false)
    where(group: group).
      where.not(icd: codes.pluck('code')).
      update_all(is_active: false) if rm

    codes.each do |icd|
      create_with(group: group, description: icd['desc']).find_or_create_by(icd: icd['code'],group: group)
    end

    where(group: group, icd: codes.pluck('code')).update_all(is_active: true)
    true
  end

  def to_s
    [icd, description].join ' - '
  end
end
