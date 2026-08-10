class Api::EncountersController < Api::BaseController
  load_and_authorize_resource class: 'Enc::Encounter'
  skip_authorize_resource only: [:can_manage, :filter]

  def can_manage
    render json: { authorized: current_user.admin? }
  end

  def destroy
    @encounter.destroy
    render json: @encounter
  end

  def diagnoses
    diagnoses = Enc::Encounter.pluck(:diagnosis)
    diagnoses.collect! {|d| [d['primary'].try(:[], 'name'), d['secondary'].try(:[], 'name')] }
    diagnoses.flatten!
    diagnoses.compact!
    diagnoses.uniq!
    diagnoses.sort!

    render json: diagnoses
  end

  def facility_pos_codes
    facility_pos_codes = Enc::Encounter.pluck(:facility_pos_code)
    facility_pos_codes.compact!
    facility_pos_codes.uniq!
    facility_pos_codes.sort!

    render json: facility_pos_codes
  end

  def md_names
    md_names = Enc::Encounter.select("referral->'md_name' as md_name").collect(&:md_name)
    md_names.flatten!
    md_names.compact!
    md_names.uniq!
    md_names.sort_by! { |data| data['val'].downcase }

    render json: md_names
  end

  def index
    @patient = patients.find(params[:patient_id])
    @encounters = @patient.encounters.order("referral->>'service_date' DESC, id DESC")

    @encounters =
      case (params[:enc_type] || '').downcase
      when 'unsigned'
        @encounters.listable.unsigned
      when 'signed'
        @encounters.listable.signed
      when 'treatment'
        @encounters.treatment_plans
      else
        @encounters.listable
      end

    if current_user.try(:incident_to_provider?)
      @encounters = @encounters.where('"enc_encounters"."incident_to_provider_id" = ? OR "enc_encounters"."cpt_encounter_code" = ?', current_user.meta.id, '90791')
    end

    if params[:simple]
      if params[:cpt]
        @encounters = @encounters.where(cpt_encounter_code: params[:cpt])
      end
      if params[:from]
        @encounters = @encounters.where("referral ->> 'service_date' > ?", params[:from].to_i.days.ago)
      end
      paginate_with_simple_serialize @encounters do
        {
          links: @encounters.pluck(:id),
          type: params[:enc_type],
        }
      end
    else
      render json: @encounters
    end
  end

  def ship_claim_md
    # admin-only endpoint
    if !current_user.admin?
      Rails.logger.info "ship_claim_md: user not admin: #{current_user.id}"
      head :forbidden
      return
    end

    if @encounter.signed? && !@encounter.signer.hold_claims? && @encounter.valid_for_charge?
      Rails.logger.info "ship_claim_md: scheduling encounter for shipping: #{@encounter.id}"
      @encounter.update_attribute(:shipped_hp_billing, nil)
      ShipBillingToClaimMdJob.perform_now([@encounter.id])
    else
      Rails.logger.info "ship_claim_md: failed to schedule encounter for shipping: #{@encounter&.id}"
      Rails.logger.info "ship_claim_md: signed?: #{@encounter&.signed?}"
      Rails.logger.info "ship_claim_md: hold_claims?: #{@encounter&.signer&.hold_claims?}"
      Rails.logger.info "ship_claim_md: valid_for_charge?: #{@encounter&.valid_for_charge?}"
    end

    head :ok
  end

  def show
    @patient = patients.find(params[:patient_id])
    @encounter = @patient.encounters.where(id: params[:id]).includes(signer: {patients: [:primary_insurance, :secondary_insurance, :tertiary_insurance]}).first
    @type = params[:type]
    @type = 'full' unless @type.in?(['full', 'no addendum', 'no note', 'partial'])

    respond_to do |format|
      format.pdf do
        pdf = PdfGenerator::Encounter.generate @encounter, user: current_user, type: @type
        send_data pdf.render, filename: @encounter.pdfname, type: "application/pdf", disposition: "attachement"
      end

      format.docx do
        doc = DocxGenerator::Encounter.generate @encounter, user: current_user, type: @type
        send_data(doc.render, {
          filename: @encounter.docxname,
          type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
          disposition: "attachement"
        })
      end

      format.json do
        render json: @encounter, include: '**'
      end
    end
  end

  def service_timestamp
    @patient = patients.find params[:patient_id]
    @encounter = @patient.encounters.find(params[:id])
    enc_params = encounter_service_params

    # avoid overwriting other values with blanket assign
    @encounter.referral.service_date = enc_params[:referral][:service_date]

    if @encounter.certification.present?
      @encounter.certification.start_time = enc_params[:certification][:start_time]
      @encounter.certification.end_time = enc_params[:certification][:end_time]

      # handle raw start/end
      tz_offset = (@encounter.certification.tz_offset_mins || 0).minutes

      start_time = Time.parse(@encounter.certification.start_time)
      @encounter.certification.start_time_raw = (raw_datetime_at(@encounter.service_date, start_time) - tz_offset).iso8601

      end_time = Time.parse(@encounter.certification.end_time)
      @encounter.certification.end_time_raw = (raw_datetime_at(@encounter.service_date, end_time) - tz_offset).iso8601
    end

    @encounter.validate_service_date = true

    if @encounter.save
      render json: @encounter
    else
      render json: @encounter.errors, status: 422
    end
  end

  def update
    @patient = patients.find params[:patient_id]
    provider = current_user.meta
    @encounter = @patient.encounters.find(params[:id])
    enc_params = encounter_params

    if provider.incident_to_provider?
      enc_params[:incident_to_provider_id] = provider.id
    end

    if @encounter.signed_on?
      # ONLY permit updating of: addendum & addendum_user_id
      unless (enc_params.keys - %w(addendum addendum_user_id incident_to_provider_id)).empty?
        raise UpdateReadOnlyRecordError,
          "Encounter##{@encounter.id} is already certified" 
      end
    end

    @encounter.certify = params[:certify]
    @encounter.provider_id = params[:provider_id]

    if @encounter.update_attributes(enc_params)
      render json: @encounter
    else
      render json: @encounter.errors, status: 422
    end
  end

  def create
    patient = patients.find params[:patient_id]
    provider = current_user.meta
    encounter = patient.create_encounter_by_type(params[:cpt_encounter_code])

    if provider.incident_to_provider?
      encounter.incident_to_provider_id = provider.id
      encounter.save
    elsif params[:cpt_encounter_code] == '90791' && patient.incident_to_provider_id.present?
      encounter.incident_to_provider_id = patient.incident_to_provider_id
      encounter.save
    end

    if encounter.errors.blank?
      render json: encounter
    else
      render json: encounter.errors.as_json
    end
  end

  def filter
    @encounters = Enc::Encounter.filter current_user, params

    if !params[:export_pdf]
      # Send back the export url to be used when 'export pdf' is clicked
      response.headers['X-EXPORT-URL'] = request.url
    end

    @encounters = @encounters.order("pat_patients.last_name ASC, referral->>'service_date' DESC")
    if params[:export_pdf].in?(['full', 'no addendum', 'no note', 'partial'])
      pdf = PdfGenerator::Encounter.generate @encounters, type: params[:export_pdf], user: current_user
      send_data pdf.render, filename: "EncounterFilter-#{Date.today.to_s}.pdf", type: "application/pdf", disposition: "attachement"
    elsif params[:simple]
      # NOTE
      # hackish hotfix because we didn't take billing report into account when adding pagination
      # probably want to find a better solution for such scenarios...
      if params[:no_pagination]
        render json: @encounters, each_serializer: Enc::EncounterSimpleSerializer
      else
        paginate_with_simple_serialize @encounters do
          {
            links: @encounters.pluck(:id, :patient_id, :signed_on).
            map{|attrs| [*attrs[0..1], attrs[-1].blank? ? 'E' : 'P'] }
          }
        end
      end
    else
      render json: @encounters, include: '**'
    end
  end

  def certs
    render json: Enc::Encounter::CERTS
  end

  private

  def encounter_params
    params[:encounter][:incident_to_provider_id] = params[:incident_to_provider_id]
    params.require(:encounter).permit!
  end

  def encounter_service_params
    params.require(:encounter).permit(certification: [:start_time, :end_time], referral: :service_date)
  end

  def max_per_page
    10
  end

  def paginate_with_simple_serialize(encounters, &meta)
    paginate encounters.count, max_per_page  do |limit, offset|
      render json: {
        data: ActiveModel::Serializer::CollectionSerializer.new(
          encounters.limit(limit).offset(offset),
          each_serializer: Enc::EncounterSimpleSerializer 
        ),
        meta: meta.call
      }
    end
  end

  def raw_datetime_at(date, time)
    DateTime.new(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.min,
      time.sec,
    )
  end

end

