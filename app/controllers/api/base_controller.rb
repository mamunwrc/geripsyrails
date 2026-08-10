class Api::BaseController < ApplicationController
  include CleanPagination

  before_action :force_json
  before_action :authenticate_user!
  before_action :set_version_header

  respond_to :json

  UpdateReadOnlyRecordError = Class.new(StandardError)

  #rescue_from StandardError do |exception|
  #  render json: {error: exception.message}, status: 500
  #end

  rescue_from UpdateReadOnlyRecordError do |exception|
    render json: {error: exception.message}, status: 409
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render json: {exception.param => "is required"}, status: 422
  end

  rescue_from ArgumentError do |exception|
    render json: {error: exception.message}, status: 422
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {error: exception.message}, status: :not_found
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json do
        render(json: {
          msg: exception.message, status: 403
        }.as_json, status: 403)
      end
    end
  end

  USER_COLS = %i(
    id
    password
    last_name
    first_name
    middle_name
    title
    suffix
    initials
    ssn
    dob
    gender
    position
    address1
    address2
    city
    state
    zip
    home_phone
    work_phone
    fax
    cell
    pager
    alternate_phone
    email
    authorization_token
    login_name
    xml_data
  )

  protected

  def patients
    _patients = if current_user.has_role? :reviewer
      current_user.meta.permitted_patients
    else
      current_user.meta.try(:patients)
    end
    return [] unless _patients
    _patients.order :last_name, :first_name
  end

  def set_version_header
    response.headers['X-GERIPSY-VERSION'] = ::GeriPsy::Application::VERSION
  end

  def max_per_page_limit
    10
  end

  def require_admin
    head :not_found if !current_user&.admin?
  end

  private

  def force_json
    request.format = :json unless request.format.to_sym.in?(%i(pdf docx))
  end

  def search_bar_filter(collection, param_name=:filter)
    if pname = params[param_name]
      pname = pname.to_s.strip.downcase
      yield collection, pname
    else
      collection
    end
  end
end
