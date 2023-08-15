# frozen_string_literal: true

module JwtAuthenticated
  extend ActiveSupport::Concern
  include JwtValidatable
  include Oauth2Clientable

  included do
    before_action :fetch_jwt
    before_action :find_user
    before_action :respond_expired_jwt
    before_action :populate_workspaces

    rescue_from(*JwtValidatable::JWT_ERRORS, with: :jwt_error_response)
  end

  private

  def fetch_jwt
    return unless Rails.cache.fetch("#{cookies.signed[:oauth_state]}/code")

    auth_code = Rails.cache.fetch("#{cookies.signed[:oauth_state]}/code")
    cookies.delete(:oauth_state)

    access_token = oauth2_client.auth_code.get_token(auth_code)
    payload = validate_jwt(access_token.response.parsed['id_token'])
    @user = User.find_or_create_by(name: payload['name'], email: payload['email'])
    session[:user_id] = @user.id
    session[:user_subject] = payload['sub']
    Rails.cache.fetch("#{@user.id}/access_token_jwt", expires_in: (4.hours - 5.minutes)) do
      access_token.response.parsed['id_token']
    end
  end

  def find_user
    return if @user
    return redirect_to new_session_path, alert: 'Login again!' unless session[:user_id]

    @user = User.find_by(id: session[:user_id])

    redirect_to new_session_path, alert: 'Login again!' unless @user
  end

  def populate_workspaces
    set_workspace_variables

    return if @workspace

    response = api_http_client.get('workspaces').body

    @workspaces = Rails.cache.fetch("#{@user.id}/workspaces") do
      response['workspaces']
    end
    session['current_workspace_id'] = response['current']

    set_workspace_variables
  end

  def set_workspace_variables
    @workspaces = Rails.cache.fetch("#{@user.id}/workspaces") || []
    @workspace = @workspaces.detect do |workspace|
      session['current_workspace_id'] == workspace['id']
    end
    @workspace_options = @workspaces.map do |workspace|
      [workspace['name'], workspace['id']]
    end
  end

  def respond_expired_jwt
    return if Rails.cache.fetch("#{@user.id}/access_token_jwt")

    session.delete(:user_id)
    redirect_to new_session_path, alert: 'Login again!'
  end

  def jwt_error_response
    redirect_to new_session_path, alert: 'JWT Parsing error (expiration, signature, etc), Try to login again!'
  end

  def api_http_client
    @api_http_client ||= HttpClient.new(ENV['IUGU_API_BASE_URL'], jwt: Rails.cache.fetch("#{@user.id}/access_token_jwt"))
  end
end
