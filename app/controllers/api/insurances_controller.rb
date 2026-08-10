class Api::InsurancesController < Api::BaseController
  load_and_authorize_resource class: 'Pat::Insurance'

  def index
    @providers = search_bar_filter Pat::Insurance.all.order(:hp_id_code) do |ins, name|
      ins.where("lower(name) like ?", "%#{name}%")
    end

    if params[:simple]
      render json: @providers
    else
      paginate @providers.count, max_per_page_limit do |limit, offset|
        render json: @providers.limit(limit).offset(offset)
      end
    end
  end

  def show
    @provider = Pat::Insurance.find params[:id]
    render json: @provider
  end

  def create
    @provider = Pat::Insurance.new insurance_params
    if @provider.save
      render json: @provider
    else
      render json: @provider.errors.as_json, status: :unprocessable_entity
    end
  end

  def update
    @provider = Pat::Insurance.find params[:id]
    if @provider.update insurance_params
      render json: @provider
    else
      render json: @provider.errors.as_json, status: :unprocessable_entity
    end
  end

  def destroy
    @provider = Pat::Insurance.find params[:id]

    if @provider.destroy
      render json: nil, status: :ok
    else
      render json: @provider.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def insurance_params
    params.require(:insurance).permit :name, :hp_id_code, :incoming_hp_code, :medicare_hmo, :payerid, :address1, :address2, :city, :state, :zip
  end
end
