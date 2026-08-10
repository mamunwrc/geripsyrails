module ControllerMacros
  def self.included(base)
    base.class_eval do
      let(:current_practice) { FactoryGirl.create :practice }
      let(:current_user) { subject.current_user }
    end
  end

  def login_super_admin
    before(:each) do
      login_super_admin!
    end
  end

  def login_admin
    before(:each) do
      login_admin!
    end
  end

  def login_admin!
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in create_user :admin
  end

  def login_reviewer
    before(:each) do
      login_reviewer!
    end
  end

  def login_reviewer!
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in create_user(:reviewer)
  end

  def login_provider
    let(:__user__) { create_user(:provider) }
    let(:provider) { __user__.meta }

    before(:each) do
      login_provider!(__user__)
    end
  end

  def login_provider!(pro=nil)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in(pro || create_user(:provider))
  end

  def login_super_admin!
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in FactoryGirl.create(:super_admin)
  end

  def login_user
    before(:each) do
      login_user!
    end
  end

  def login_user!
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:user, practice: current_practice)
    sign_in user
  end

  def setup_patient!
    let(:facility) { FactoryGirl.create :facility, practice: current_practice }
    let(:patient) { FactoryGirl.create :patient, practice: current_practice, facility: facility }
  end

  def setup_non_associated_patient!
    let(:diff_practice) { FactoryGirl.create :practice}
    let(:facility) { FactoryGirl.create :facility, practice: diff_practice }
    let(:patient) { FactoryGirl.create :patient, practice: diff_practice, facility: facility }
  end

  private

  def create_user(type)
    user = FactoryGirl.create(type, practice: current_practice).user
    user.update practice: current_practice
    user
  end
end

