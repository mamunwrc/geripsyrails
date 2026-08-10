require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html, :json

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :reset_session, prepend: true

  before_action :set_raven_context
  after_action :set_csrf_cookie_for_ng

  def index
  end

  private

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def verified_request?
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
  end

  def set_raven_context
    Raven.user_context({
      id: current_user.try(:id),
      email: current_user.try(:email)
    })
    Raven.extra_context params: params.to_unsafe_h, url: request.url
  end
end
