class Role < ApplicationRecord
  audited

  has_and_belongs_to_many :users, :join_table => :usr_users_roles, class_name: "::Usr::User", foreign_key: 'user_id'

  belongs_to :resource,
             :polymorphic => true

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  scopify
end
