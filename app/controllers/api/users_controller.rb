class Api::UsersController < Api::BaseController
  def update
    if params[:id].to_i != current_user.id
      render json: {error: 'forbidden', msg: 'you do not have permission to do that'}, status: :forbidden
    else
      if current_user.update(user_params)
        Rails.logger.info "INCOMING PARAMS: #{user_params.inspect}"
        render json: current_user
      else
        render json: {error: 'invalid', errors: current_user.errors}
      end
    end
  end

  def user_params
    params.require(:user).permit(:timezone)
  end
end
