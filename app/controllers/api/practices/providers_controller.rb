class Api::Practices::ProvidersController < ::Api::BaseController
  def index
    @providers = practice.providers

    respond_with @providers
  end

  def create
    @provider = Usr::Provider.find params[:id]
    practice.users << @provider.user
    render json: @provider
  end

  def destroy
    @user = practice.users.where(id: params[:id])
    practice.users.delete @user

    render json: practice.users
  end

  private

  def practice
    @practice ||= Adm::Practice.find params[:practice_id]
  end
end
