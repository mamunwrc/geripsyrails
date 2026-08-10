class Api::GroupEncountersController < Api::BaseController
  authorize_resource class: 'Grp::Encounter'

  def index
    render json: group.encounters.includes(:patients, :patient_notes).order('signed_on DESC')
  end

  def show
    @encounter = group.encounters.find(params[:id])

    respond_to do |format|
      format.pdf do
        pdf = PdfGenerator::Encounter.generate(@encounter.session_encounters, user: current_user, type: params[:type])
        send_data pdf.render, filename: @encounter.pdfname, type: 'application/pdf', disposition: 'attachment'
      end

      format.docx do
        zip = Zip::OutputStream.write_buffer do |zio|
          @encounter.session_encounters.each do |enc|
            docx = DocxGenerator::Encounter.generate(enc, user: current_user, type: params[:type]).render
            zio.put_next_entry enc.docxname
            zio.write docx
          end
        end

        send_data(zip.string, {
          filename: @encounter.docxname,
          type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
          disposition: "attachement"
        })
      end

      format.json do
        render json: @encounter
      end
    end
  end

  def create
    #@encounter = group.encounters.create(encounter_params)
    @encounter = group.create_encounter!
    render json: @encounter
  end

  def update
    @encounter = group.encounters.find(params[:id])
    @encounter.certify = params[:certify]
    @encounter.provider_id = params[:provider_id]

    unless @encounter.unsigned?
      raise UpdateReadOnlyRecordError, "Encounter##{@encounter.id} is already certified"
    end

    begin
      if @encounter.update(encounter_params)
        render json: group.reload
      else
        render json: @encounter.errors, status: 422
      end
    rescue Grp::Encounter::CannotCertifyIndividualNotesError
      render json: @encounter.errors, status: 422
    end
  end

  def check_date
    date = params[:date].to_date
    encounter = group.encounters.find(params[:id])
    encs = Enc::Encounter.where({
      patient_id: encounter.session_patients.pluck(:id),
      cpt_encounter_code: %w(90791 90853)
    }).service_date_between(date, date.next)
    render json: {valid: encs.blank?, patients: encs.pluck(:patient_id)}
  end

  def addendumize
    @encounter = group.encounters.find(params[:id])
    if current_user.provider?
      @encounter.addendums.create({
        note: params[:addendum],
        user_id: current_user.id
      })
      render json: @encounter
    else
      render json: {error: 'Only provider can add addendum'}, status: 422
    end
  end

  private

  def group
    @group ||= current_user.groups.find(params[:group_id])
  end

  def encounter_params
    # ugh have to use #permit! here and in EncountersController
    # until rails 5.1
    invalid_params = %i(patient_notes certified patient_count)
    invalid_params.each {|param| params[:group_encounter].delete(param) }

    params.require(:group_encounter).permit!
  end
end
