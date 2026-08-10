class Api::PatientsController < Api::BaseController
  load_and_authorize_resource class: 'Pat::Patient'

  def index
    if params[:limitless]
      render json: patients, include: '**'
    elsif params[:simple]
      render json: simple_patients, each_serializer: Pat::PatientSimpleSerializer
    elsif params[:with_tp]
      paginate tp_patients.count, max_per_page_limit do |limit, offset|
        render json: tp_patients.limit(limit).offset(offset),
          each_serializer: Pat::PatientTPSerializer
      end
    else
      @patients = patient_search_bar_filter(patients)

      if (status=params[:status].to_s.strip).in?( %w(active inactive) )
        @patients = @patients.send(status)
      end

      @patients = @patients.includes(:facility, providers: %i(user))
      paginate @patients.count, max_per_page_limit do |limit, offset|
        render json: @patients.limit(limit).offset(offset), each_serializer: Pat::PatientSimpleSerializer
      end
    end
  end

  def notes
    @patient = patients.find(params[:id])

    if %i(provider admin).any?{|role| current_user.has_role?(role) }
      @patient.notes.create(text: params[:note_text], user: current_user)
      render json: @patient, include: '**'
    else
      head :forbidden
    end
  end

  def match
    collection = patients.where(
      "lower(first_name) = ? AND lower(last_name) = ?",
      *%i(first_name last_name).map{|k| (params[k] || '').downcase }
    )

    render json: collection, each_serializer: Pat::PatientSimpleSerializer
  end

  def show
    @patient = patients.find(params[:id])
    render json: @patient, include: '**'
  end

  def update
    @patient = patients.find(params[:id])

    if @patient.update_attributes(attrs)
      render json: @patient, include: '**'
    else
      render json: @patient.errors.as_json, status: 422
    end
  end

  def create
    @patient = Pat::Patient.new attrs

    if @patient.save
      if current_user.has_role?(:provider)
        current_user.meta.patients << @patient
      end
      render json: @patient, include: '**'
    else
      render json: @patient.errors.as_json, status: 422
    end
  end

  def treatment_plan
    @patient = patients.find(params[:id])
    @treatment_plan = @patient.treatment_plans.last
    render json: @treatment_plan, include: '**'
  end

  def encounter_dates
    @patient = patients.find(params[:id])
    render json: @patient.encounters.signed.non_dupable.map(&:service_date)
  end

  def filter
    @practice = current_user.practice || current_user.meta.practice
    raise StandardError, "no practice_id" unless @practice

    @patients = @practice.patients.includes(:facility, :primary_insurance, :secondary_insurance, :tertiary_insurance, { providers: :user })

    if params[:provider_ids]
      @providers = @practice.providers.where id: params[:provider_ids]
      @patients = @patients.where id: @providers.map(&:patient_ids).flatten
    end

    if params[:incident_to_provider_ids]
      @incident_to_providers = @practice.providers.where id: params[:incident_to_provider_ids]
      @patients = @patients.where id: @incident_to_providers.map(&:incident_to_patient_ids).flatten
    end

    if params[:facility_ids]
      @facilities = @practice.facilities.where id: params[:facility_ids]
      @patients = @patients.where id: @facilities.map(&:patient_ids).flatten
    end

    if params[:prim_insurance]
      @patients = @patients.where "insurance_data->'primary'->'type'->>'name' = ?", params[:prim_insurance]
    end

    if params[:sec_insurance]
      @patients = @patients.where "insurance_data->'secondary'->'type'->>'name' = ?", params[:sec_insurance]
    end

    if params[:primary_insurance_id]
      @patients = @patients.where(primary_insurance_id: params[:primary_insurance_id])
    end

    if params[:secondary_insurance_id]
      @patients = @patients.where(secondary_insurance_id: params[:secondary_insurance_id])
    end

    if params[:genders]
      @patients = @patients.where(gender: params[:genders])
    end

    if params[:diagnoses]
      @patients = @patients.joins(:encounters).where(
        "((enc_encounters.diagnosis->'primary'->'name')::jsonb ?| array[:diagnoses]) OR ((enc_encounters.diagnosis->'secondary'->'name')::jsonb ?| array[:diagnoses])",
        diagnoses: params[:diagnoses]
      )
    end

    if params[:ssn]
      @patients = @patients.where(ssn: params[:ssn])
    end

    if params[:statuses]
      @patients = @patients.where(status: params[:statuses])
    end

    if params[:facility_pos_codes]
      @patients = @patients.joins(:encounters).where(enc_encounters: {facility_pos_code: params[:facility_pos_codes]})
    end

    if params[:room_num]
      @patients = @patients.where(room_num: params[:room_num])
    end

    if params[:birth_date_from] || params[:birth_date_to]
      params[:birth_date_from] ||= Time.at(0).utc.to_date.to_s
      params[:birth_date_to] ||= Date.tomorrow.to_s

      from = Date.parse params[:birth_date_from]
      to = Date.parse(params[:birth_date_to]) + 1

      @patients = @patients.where(dob: [from..to])
    end

    encounters = Enc::Encounter.where(patient_id: @patients.pluck(:id))
    encounters = encounters.where(signed_by: params[:provider_ids]) if params[:provider_ids]

    service_dates = Hash.new {|h,k| h[k] = []}
    if params[:from] || params[:to]
      params[:from] ||= '1970-01-01'
      params[:to] ||= Date.tomorrow.to_s

      from = Date.parse params[:from]
      to = Date.parse(params[:to]) + 1

      encounter_data = encounters.service_date_between(from, to).pluck(:patient_id, :sd_utc)
      encounter_data.each { |patient_id, service_date| service_dates[patient_id] << service_date }

      @patients = Pat::Patient.where(id: service_dates.keys)
    else
      encounters = encounters.select(:patient_id, :referral)
      encounters.each { |encounter| service_dates[encounter.patient_id] << encounter.service_date }
    end

    service_dates.each_value(&:sort!)

    if !params[:export_pdf]
      response.headers['X-EXPORT-URL'] = request.url
    end

    if params[:export_pdf]
      @patients.each { |patient| patient.service_dates = service_dates[patient.id] }
      pdf = PdfGenerator::Patient.generate [@patients], type: params[:export_pdf], user: current_user, providers: @providers
      send_data pdf.render, filename: "PatientFilter-#{Date.today.to_s}.pdf", type: "application/pdf", disposition: 'inline'
    else
      render json: @patients.order('last_name'), each_serializer: Pat::PatientFilterSerializer, providers: @providers, service_dates: service_dates
    end
  end

  def check_service_date
    @patient = patients.find(params[:id])
    date = params[:date]
    cpt  = params[:cpt]
    enc  = params[:enc]

    dup_check = Enc::ServiceDateDupCheck.run(@patient.id, cpt, Date.parse(date.to_s), enc)

    if dup_check.ok?
      render json: {is_dup: 'no'}
    else
      render json: {is_dup: 'yes'}
    end
  end

  private

  def attrs
    _attrs = patient_params

    if params[:insurance_data]
      params[:insurance_data].permit!
      _attrs = patient_params.merge insurance_data: params[:insurance_data]
    end

    _attrs
  end

  def patient_response(obj=nil)
    (obj || @patient).as_json include: {facility: {include: [:doctors]}}
  end

  def patient_params
    params.require(:patient).permit(%i(death_date dob employer employment_status ethnicity first_name language last_name marital_status middle_name mrn note occupation race ssn status suffix title gender facility_id room_num primary_insurance_id secondary_insurance_id tertiary_insurance_id primary_insurance_number secondary_insurance_number tertiary_insurance_number primary_provider_id facility_pos_code testing_provider_id prior_authorization_number incident_to_provider_id))
  end

  def simple_patients
    patients.includes(providers: %i(user)).includes(:facility)
  end

  def tp_patients
    _pats =
      if current_user.provider?
        patients.where(primary_provider_id: current_user.meta_id)
      else
        patients
      end
    patient_search_bar_filter(_pats).pending_tp.includes(providers: %i(user)).includes([:encounters])
  end

  def patient_search_bar_filter(pats)
    search_bar_filter(pats) do |_pats, name|
      _pats.where("lower(first_name) like ?", "%#{name}%").or(_pats.where("lower(last_name) like ?", "%#{name}%"))
    end
  end
end
