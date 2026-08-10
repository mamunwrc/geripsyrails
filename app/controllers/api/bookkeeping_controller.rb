class Api::BookkeepingController < Api::BaseController
  before_action :require_admin

  def create
    MonthlyBookkeepingJob.perform_later(date_string)

    head :created
  end

  private

  def date_string
    date = Date.parse(params[:bookkeeping][:date]) rescue Date.today
    date.rfc3339
  end

end
