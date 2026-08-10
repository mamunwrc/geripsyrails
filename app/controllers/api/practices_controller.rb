class Api::PracticesController < Api::BaseController
  load_and_authorize_resource class: 'Adm::Practice'

  respond_to :json

  def index
    if current_user.has_role?(:super_admin)
      @practices = Adm::Practice.all
    else
      @practices = Adm::Practice.where(id: current_user.meta.practice_id)
    end

    if params[:simple]
      render json: @practices, each_serializer: Adm::PracticeSimpleSerializer
    else
      paginate @practices.count, max_per_page_limit do |limit, offset|
        render json: @practices.limit(limit).offset(offset), include: '**'
      end
    end
  end

  def show
    @practice = Adm::Practice.find params[:id]
    render json: @practice, include: '**'
  end

  def create
    @practice = Adm::Practice.new(practice_params)
    if @practice.save
      render json: practice_response
    else
      render json: @practice.errors.as_json, status: :unprocessable_entity
    end
  end

  def update
    @practice = Adm::Practice.find params[:id]
    if @practice.update_attributes practice_params
      render json: @practice, include: '**'
    else
      render json: @practice.errors.as_json, status: :unprocessable_entity
    end
  end

  private

  def practice_response
    @practice.as_json(include: [:users])
  end

  def practice_params
    params.require(:practice).permit :name, :practice_type, :address1, :address2, :city, :state, :zip, :country, :admin_id, :tax_number, :reviewer_id
  end
end

