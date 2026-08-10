class Api::ShippingController < Api::BaseController
  before_action :require_admin

  def ship
    HpResenderJob.perform_later

    head :created
  end

end
