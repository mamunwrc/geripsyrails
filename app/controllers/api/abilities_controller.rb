class Api::AbilitiesController < Api::BaseController
  respond_to :json
  def index
    respond_with current_user.abilities
  end
end
