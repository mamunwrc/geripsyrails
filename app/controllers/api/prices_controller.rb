class Api::PricesController < Api::BaseController
  load_and_authorize_resource class: 'Adm::CptPrice'

  def index
    @prices = search_bar_filter Adm::CptPrice.all.order(:cpt_code) do |prices, cpt_code|
      prices.where("lower(cpt_code) like ?", "%#{cpt_code}%")
    end

    if params[:simple]
      render json: @prices
    else
      paginate @prices.count, max_per_page_limit do |limit, offset|
        render json: @prices.limit(limit).offset(offset)
      end
    end
  end

  def show
    @price = Adm::CptPrice.find params[:id]
    render json: @price
  end

  def create
    @price = Adm::CptPrice.new price_params
    if @price.save
      render json: @price
    else
      render json: @price.errors.as_json, status: :unprocessable_entity
    end
  end

  def update
    @price = Adm::CptPrice.find params[:id]
    if @price.update price_params
      render json: @price
    else
      render json: @price.errors.as_json, status: :unprocessable_entity
    end
  end

  def destroy
    @price = Adm::CptPrice.find params[:id]

    if @price.destroy
      render json: nil, status: :ok
    else
      render json: @price.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def price_params
    params.permit(:cpt_code, :price)
  end
end
