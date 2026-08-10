class Api::Providers::PatientsController < Api::BaseController
  def create
    @provider = current_user.meta.providers.find params[:provider_id]
    @patient = patients.find params[:id]
    @provider.patients << @patient

    render json: @provider
  end

  def destroy
    @provider = current_user.meta.providers.find params[:provider_id]
    @patient = patients.find params[:id]
    @patient.reprimarize! if @patient.primary_provider_id == @provider.id
    @provider.patients.delete @patient

    render json: @provider
  end
end
