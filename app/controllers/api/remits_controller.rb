class Api::RemitsController < Api::BaseController
  skip_before_action :authenticate_user!

  def import
    @practice = Adm::Practice.find_by(remit_token: params[:token])
    unless @practice
      render json: {status: :unauthorized}, status: 403
    else
      @response = Adm::RemitBatch::ImportResponder.new(@practice.id)
      if params[:files].blank?
        @response.status = :error
        @response.error = {msg: 'no files sent'}
      else
        @batch = Adm::RemitBatch.new({
          batch_date: Date.today,
          payload: {files: params.to_unsafe_h[:files]},
          ip: request.remote_ip,
          practice_id: @practice.id,
          token: params[:token]
        })

        if @batch.save
          @response.remits = @batch.import!
          @response.remits.each.with_index {|r, idx|
            r.key = "UNKNOWN#{idx}" if r.key.blank?
          }
        else
          @response.status = :error
          @response.error = { msg: "Error importing remits :: #{@batch.errors.to_messages}" }
        end
      end
      render json: @response.to_response
    end
  end


end

