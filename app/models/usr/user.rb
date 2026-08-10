class Usr::User < ApplicationRecord
  audited except: %i(
    encrypted_password
    reset_password_token
    reset_password_sent_at
    remember_created_at
    sign_in_count
    current_sign_in_at
    last_sign_in_at
    current_sign_in_ip
    last_sign_in_ip
    confirmation_token
    confirmed_at
    confirmation_sent_at
    unconfirmed_email
    failed_attempts
    unlock_token
    locked_at
  )

  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable, :timeoutable

  belongs_to :meta, polymorphic: true, optional: true
  belongs_to :practice, class_name: 'Adm::Practice', optional: true

  before_save :ensure_practice

  enum timezone: TIMEZONES, _prefix: true

  def abilities
    abilities = Ability.new(self)
    abilities.permissions
  end

  def full_name
    [first_name, last_name].join ' '
  end

  def timeout_in
    6.hours
  end

  def encounter_filter(opts={})
    Enc::Encounter.filter self, opts
  end

  def groups
    case meta_type
    when 'Usr::Provider'
      meta.groups
    when 'Usr::Admin'
      Grp::Group.where(practice_id: practice_id)
    else
      []
    end
  end

  def incident_to_provider?
    meta.try(:incident_to_provider?)
  end

  def provider?
    meta_type == 'Usr::Provider'
  end

  def admin?
    meta_type == 'Usr::Admin'
  end

  private

  def ensure_practice
    self.practice_id = meta.try(:practice_id)
  end
end

