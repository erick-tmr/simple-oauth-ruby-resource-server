# frozen_string_literal: true

module Oauth2Clientable
  def oauth2_client
    @oauth2_client ||= OAuth2::Client.new(ENV['IUGU_CLIENT_ID'], ENV['IUGU_CLIENT_SECRET'],
                                          site: ENV['IUGU_BASE_URL'],
                                          token_url: '/token',
                                          authorize_url: '/authorize',
                                          redirect_uri: ENV['OAUTH_CALLBACK_URL'])
  end
end
