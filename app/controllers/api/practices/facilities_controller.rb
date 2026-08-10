class Api::Practices::FacilitiesController < Api::BaseController
  def index
    @facilities = practice.facilities
    respond_with @providers
  end

  def create
    @facility = Adm::Facility.find params[:id]
    practice.facilities << @facility
    render json: @facility
  end

  def destroy
    @facility = Adm::Facility.find params[:id]
    practice.facilities.delete @facility

    render json: practice.facilities
  end

  private

  def practice
    @practice ||= Adm::Practice.find params[:practice_id]
  end
end
