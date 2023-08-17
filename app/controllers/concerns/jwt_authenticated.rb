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
    payload = validate_and_store_jwt(access_token)
    session[:user_id] = @user.id
    session[:user_subject] = payload['sub']
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
    @workspaces = Rails.cache.read("#{@user.id}/workspaces") || []
    @workspace = @workspaces.detect do |workspace|
      session['current_workspace_id'] == workspace['id']
    end
    @workspace_options = @workspaces.map do |workspace|
      [workspace['name'], workspace['id']]
    end
  end

  def respond_expired_jwt
    return if Rails.cache.read("#{@user.id}/access_token_jwt")
    return if refresh_token

    session.delete(:user_id)
    redirect_to new_session_path, alert: 'Login again!'
  end

  def refresh_token
    return false unless Rails.cache.read("#{@user.id}/access_token_hash")

    access_token = OAuth2::AccessToken.from_hash(
      oauth2_client,
      Rails.cache.read("#{@user.id}/access_token_hash")
    )

    begin
      new_access_token = access_token.refresh
    rescue OAuth2::Error
      return false
    end

    validate_and_store_jwt(new_access_token)
  end

  def validate_and_store_jwt(access_token)
    payload = validate_jwt(access_token.response.parsed['id_token'])
    token_ttl = (Time.at(payload['exp']) - Time.zone.now).to_i - 30
    @user ||= User.find_or_create_by(name: payload['name'], email: payload['email'])
    Rails.cache.write(
      "#{@user.id}/access_token_jwt",
      access_token.response.parsed['id_token'],
      expires_in: token_ttl
    )
    Rails.cache.write(
      "#{@user.id}/access_token_hash",
      access_token.to_hash,
      expires_in: (token_ttl + 13.minutes)
    )

    payload
  end

  def jwt_error_response
    redirect_to new_session_path, alert: 'JWT Parsing error (expiration, signature, etc), Try to login again!'
  end

  def api_http_client
    @api_http_client ||= HttpClient.new(ENV['IUGU_API_BASE_URL'], jwt: Rails.cache.read("#{@user.id}/access_token_jwt"))
  end
end
