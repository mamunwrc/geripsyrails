class Api::ReviewersController < Api::BaseController
  load_and_authorize_resource class: 'Usr::Reviewer'

  def index
    @reviewers = practice.reviewers
    paginate @reviewers.count, max_per_page_limit do |limit, offset|
      render json: @reviewers.limit(limit).offset(offset), include: '**'
    end
  end

  def show
    @reviewer = practice.reviewers.find params[:id]
    render json: @reviewer, include: '**'
  end

  def create
    @reviewer = practice.reviewers.new reviewer_params
    if @reviewer.save
      @reviewer.user.add_role :reviewer
      render json: @reviewer, include: '**'
    else
      render json: @reviewer.errors, status: 422
    end
  end

  def update
    @reviewer = practice.reviewers.find params[:id]
    if @reviewer.update_attributes reviewer_params
      render json: @reviewer, include: '**'
    else
      render json: @reviewer.errors, status: 422
    end
  end

  def destroy
    @reviewer = practice.reviewers.find params[:id]

    if @reviewer.destroy
      render json: nil, status: :ok
    else
      render json: @reviewer.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def practice
    @practice = current_user.practice || current_user.meta.try(:practice)
  end

  def reviewer_params
    params.require(:reviewer).permit :reviewer_type, user_attributes: USER_COLS, associated_patients: [], associated_facilities: [], associated_providers: []
  end
end

