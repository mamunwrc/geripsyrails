class Api::FacilitiesController < Api::BaseController
  load_and_authorize_resource class: 'Adm::Facility'

  def index
    @facilities = current_user.meta.try(:facilities)
    if @facilities
      if params[:simple]
        render json: @facilities, each_serializer: Adm::FacilitySimpleSerializer
      else
        paginate @facilities.count, max_per_page_limit do |limit, offset|
          render json: @facilities.limit(limit).offset(offset), include: '**'
        end
      end
    end
  end

  def show
    if current_user.meta
      @facility = current_user.meta.facilities.find params[:id]
      render json: @facility, include: '**'
    else
      render json: { msg: "unauthorized" }, status: 403
    end
  end

  def create
    @facility = Adm::Facility.new(facility_params)
    @facility.practice_id = current_user.meta.try(:practice_id)

    if @facility.save
      render json: @facility, include: '**'
    else
      render json: @facility.errors.as_json, status: :unprocessable_entity
    end
  end

  def update
    @facility = Adm::Facility.find params[:id]
    if @facility.update facility_params
      render json: @facility, include: '**'
    else
      render json: @facility.errors.as_json, status: :unprocessable_entity
    end
  end

  private

  def facility_response(obj=nil)
    (obj || @facility).as_json include: [:doctors]
  end

  def facility_params
    params.require(:facility).permit :name, :npi, :address1, :address2, :city, :state, :zip, :country, :admin_email, :work_phone, :home_phone, :admin_first_name, :admin_last_name, :medicare, :hp_main_pos_code, :hp_alt_pos_code, {doctor_attributes: [:id, :name]}
  end
end

