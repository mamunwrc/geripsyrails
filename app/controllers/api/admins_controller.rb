class Api::AdminsController < Api::BaseController
  load_and_authorize_resource class: 'Usr::Admin'

  def index
    @admins = Usr::Admin.all
    paginate @admins.count, max_per_page_limit do |limit, offset|
      render json: @admins.limit(limit).offset(offset), include: '**'
    end
  end

  def show
    @admin = Usr::Admin.find params[:id]
    render json: @admin, include: '**'
  end

  def create
    @admin = Usr::Admin.new admin_params
    if @admin.save
      @admin.user.add_role :admin
      render json: @admin, include: '**'
    else
      render json: @admin.errors, status: 422
    end
  end

  def update
    @admin = Usr::Admin.find params[:id]
    if @admin.update_attributes admin_params
      render json: @admin, include: '**'
    else
      render json: @admin.errors, status: 422
    end
  end

  private

  def admin_params
    params.require(:admin).permit :practice_id, user_attributes: USER_COLS
  end

  def max_per_page_limit
    20
  end
end

