class Api::ProvidersController < Api::BaseController
  load_and_authorize_resource class: 'Usr::Provider'
  skip_authorize_resource only: [:incident_to_providers, :testings]

  def index
    if current_user.has_role?(:super_admin)
      @providers = Usr::Provider.all
    elsif current_user.has_role?(:reviewer) && current_user.meta.reviewer_type == "provider"
      @providers = current_user.meta.reviewers
    else
      @providers = Usr::Provider.where(practice_id: current_user.meta.try(:practice_id))
    end

    if params[:simple]
      render json: @providers, each_serializer: Usr::ProviderSimpleSerializer
    else
      paginate @providers.count, max_per_page_limit do |limit, offset|
        render json: @providers.limit(limit).offset(offset)
      end
    end
  end

  def show
    @provider = Usr::Provider.includes(patients: [
     :primary_insurance,
     :secondary_insurance,
     :tertiary_insurance
    ]).find(params[:id])
    render json: @provider, include: '**'
  end

  def create
    @provider = Usr::Provider.new(provider_params)
    @provider.practice_id = current_user.meta.try(:practice_id)

    if @provider.save
      @provider.user.add_role :provider
      @provider.patient_ids = params[:provider][:patient_ids]
      render json: @provider, include: '**'
    else
      render json: @provider.errors.as_json, status: :unprocessable_entity
    end
  end

  def update
    @provider = Usr::Provider.find(params[:id])
    if @provider.update_attributes(provider_params)
      @provider.patient_ids = params[:provider][:patient_ids]
      render json: @provider, include: '**'
    else
      render json: @provider.errors.as_json, status: 422
    end
  end

  def incident_to_providers
    providers = if current_user.has_role?(:admin)
      Usr::Provider.where.not(linked_provider_id: nil)
    else
      Usr::Provider.where(linked_provider_id: curent_user.id)
    end

    render json: providers, each_serializer: Usr::ProviderSimpleSerializer
  end

  def testings
    @providers = Usr::Provider.all.where.not(id: params[:id])
    render json: @providers, each_serializer: Usr::ProviderSimpleSerializer
  end

  private

  ACCESSIBLE_COLS = %i(
    provider_code
    external_provider_code
    degree
    position
    speciality_license_number
    medical_license_number
    tax_number
    status
    dea_number
    dea_extension
    upin
    npi
    ptan
    medicare_id
    medicaid_id
    hmo_id
    bank_account_number
    bank_routing_number
    can_prescribe
    xml_data
    tp_required
    hp_account
    hold_claims
    linked_provider_id
  )

  def provider_params
    cols = ACCESSIBLE_COLS.dup
    cols << { user_attributes: USER_COLS, licenses_attributes: [:id, :number, :state, :expiration]  }
    params.require(:provider).require(:user_attributes)
    params.require(:provider).permit cols
  end
end

