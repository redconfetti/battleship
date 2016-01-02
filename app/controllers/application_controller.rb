class ApplicationController < ActionController::Base

  respond_to :html, :json

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def respond_with_error(status, error)
    error_json = { error: error.to_s }.to_json
    render(json: error_json, status: status.to_sym) and return
  end

  rescue_from Exceptions::ClientError, with: :handle_client_error
  rescue_from Exceptions::ServerError, with: :handle_server_error

  def handle_client_error(error)
    render json: { :error => error.message }.to_json, status: error.status_symbol
  end

  def handle_server_error(error)
    Rails.logger.error "#{error.class} raised with in #{controller_name}\##{action_name}: #{error.message}"
    render json: { :error => error.message }.to_json, status: error.status_symbol
  end
end
