class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= Usr::User.new

    if user.has_role?(:super_admin)
      can [ :manage, :update ], Adm::Practice
      can [ :manage, :update ], Usr::Admin

      # duplicating creates cuz behavior of cancan is kind of inconsistent.
      # listing `can :manage, Model` with conditions (such as in :admin)
      # allows :create as well. duplicating :create here will make it easier
      # to grab proper permissions in the front-end by only looking at :create
      can :create, Adm::Practice
      can :create, Usr::Admin
    elsif user.has_role?(:admin)
      can [:manage, :update], Adm::Practice, id: user.meta.practice_id
      can [:manage, :update], Usr::Provider, practice_id: user.meta.practice_id
      can [:manage, :update], Pat::Patient, practice_id: user.meta.practice_id
      can [:manage, :update], Adm::Facility, practice_id: user.meta.practice_id
      can [:manage, :update], Adm::FacilityContact, facility: {practice_id: user.meta.practice_id}
      can [:manage, :update], Usr::Reviewer
      can [:manage, :update], Pat::Insurance
      can [:manage, :update], Adm::CptPrice
      can [:manage, :update], Grp::Group, practice_id: user.meta.practice_id

      can [:manage], Enc::Encounter, patient: {practice_id: user.meta.practice_id}
      can :read, Grp::Encounter, group: {practice_id: user.meta.practice_id}

      can :create, Usr::Provider
      can :create, Pat::Patient
      can :create, Adm::Facility
      can :create, Usr::Reviewer
      can :create, Pat::Insurance
      can :create, Adm::CptPrice

      cannot :create, Adm::Practice
      cannot :create, Grp::Group
    elsif user.has_role?(:reviewer)
      can :read, Adm::Facility, practice_id: user.meta.practice_id
      case user.meta.reviewer_type.to_sym
      when :practice
        can :read, Pat::Patient, practice_id: user.meta.practice_id
        can :read, Enc::Encounter, patient: { practice_id: user.meta.practice_id}
        can :read, Usr::Provider, practice_id: user.meta.practice_id
        can :read, Adm::Facility, practice_id: user.meta.practice_id
      when :facility
        can :read, Pat::Patient, facility_id: user.meta.associated_facilities
        can :read, Enc::Encounter, patient: {facility_id: user.meta.associated_facilities }
        can :read, Usr::Provider, practice_id: user.meta.practice_id
      when :provider
        can :read, Pat::Patient, providers: { id: user.meta.associated_providers }
        can :read, Enc::Encounter, patient: { providers: { id: user.meta.associated_providers } }
      when :patient
        can :read, Pat::Patient, id: user.meta.associated_patients
        can :read, Enc::Encounter, patient_id: user.meta.associated_patients
      end
    elsif user.has_role?(:provider)
      user_meta = user.meta
      if user_meta.incident_to_provider?
        user_meta = user.meta.linked_provider
        can [:manage, :update], Pat::Patient, id: user.meta.incident_to_patients.pluck(:id)
      end

      can [:manage, :update], Pat::Patient, id: user.meta.patient_ids, facility_id: user_meta.practice.facility_ids
      can [:manage, :update], Enc::Encounter, patient: { id: user_meta.patient_ids, facility_id: user_meta.practice.facility_ids}
      can [:manage, :update], Grp::Group, id: user_meta.group_ids
      can [:manage, :update], Grp::Encounter, group_id: user_meta.group_ids

      can :read, Adm::Facility, id: user_meta.facility_ids
      can :read, Usr::Provider, id: user_meta.id
      can :read, Pat::Insurance

      can :create, Grp::Encounter
      can :create, Pat::Patient
      can :create, Enc::Encounter
      can :create, Grp::Group
    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
