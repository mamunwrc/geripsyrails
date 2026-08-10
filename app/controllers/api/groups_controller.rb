class Api::GroupsController < Api::BaseController
  load_and_authorize_resource class: 'Grp::Group'

  def index
    @groups = current_user.groups
    render json: @groups
  end

  def show
    @group = current_user.groups.includes(:patients, :providers, {
      encounters: {
        patient_notes: [:patients]
      }
    }).find(params[:id])
    render json: @group, includes: [:patients, :providers]
  end

  def create
    @group = current_user.groups.new(group_params.merge(practice_id: current_user.practice_id))
    @group.providers << current_user.meta if current_user.provider?

    if @group.save
      render json: @group
    else
      render json: @group.errors.as_json, status: 422
    end
  end

  def update
    @group = current_user.groups.find(params[:id])
    if @group.update(group_params)
      render json: @group
    else
      render json: @group.errors.as_json, status: 422
    end
  end

  private

  def group_params
    props = [:name]
    props += [:contact_email, :contact_active] if current_user.admin?
    params.require(:group).permit(*props, incoming_patient_ids: [])
  end
end
