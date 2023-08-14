# frozen_string_literal: true

class OauthController < ApplicationController
  include Oauth2Clientable

  def authorize
    state = SecureRandom.uuid
    cookies.signed[:oauth_state] = state

    redirect_to oauth2_client.auth_code.authorize_url(state:), allow_other_host: true
  end

  def callback
    return redirect_to new_session_path, alert: 'NONCE STATE could not be verified, Try to login again!' unless verified_state?
    return redirect_to new_session_path, alert: 'OAuth code not received, Try to login again!' unless params[:code]

    Rails.cache.fetch("#{params[:state]}/code", expires_in: 1.minute) { params[:code] }

    redirect_to root_path
  end

  private

  def verified_state?
    params[:state] == cookies.signed[:oauth_state]
  end
end
