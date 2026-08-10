class Api::FacilityContactsController < Api::BaseController
  load_and_authorize_resource class: 'Adm::FacilityContact'

  before_action :facilitize

  def create
    @facility_contact = @facility.facility_contacts.new(facility_contact_params)
    if @facility_contact.save
      render json: @facility_contact
    else
      render json: @facility_contact.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    @facility_contact = @facility.facility_contacts.find(params[:id])
    if @facility_contact.update_attributes(facility_contact_params)
      render json: @facility_contact
    else
      render json: @facility_contact.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    if @facility_contact.destroy
      render json: @facility_contact
    else
      render json: @facility_contact.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def facility_contact_params
    params.require(:facility_contact).permit!
  end

  def facilitize
    @facility = Adm::Facility.find params[:facility_id]
  end
end
