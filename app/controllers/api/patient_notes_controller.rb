class Api::PatientNotesController < Api::BaseController
  def create
    encounter.patient_notes.create(note_params)
    render json: group
  end

  def show
    render json: note(:patients), include: 'patients'
  end

  def update
    note.update note_params
    render json: group
  end

  def destroy
    note.destroy
    render json: group
  end

  private

  def note(*incs)
    @note ||= encounter.patient_notes.includes(incs).find(params[:id])
  end

  def group
    @group ||= current_user.groups.find(params[:group_id])
  end

  def encounter
    @encounter ||= group.unsigned_encounter
  end

  def note_params
    params.require(:patient_note).permit(:body, :confidential, incoming_patient_ids: [])
  end
end
