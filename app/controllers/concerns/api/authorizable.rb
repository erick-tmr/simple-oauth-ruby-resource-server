# frozen_string_literal: true

module Api
  module Authorizable
    extend ActiveSupport::Concern

    include Oauth2Clientable

    included do
      before_action :refresh_console_token
    end

    def authorize_action(action_name, workspace_id)
      authorize_body = {
        w: workspace_id,
        p: @token['sub'],
        a: action_name
      }

      response = indentity_http_client.post('verify', body: authorize_body)
      @authorized = response.body == '1'
    end

    private

    def refresh_console_token
      return if Rails.cache.fetch('console-token')

      response = oauth2_client.client_credentials.get_token(audience: 'Iugu.Platform.0mWyr4AfdWVp22yzQ7jiL9')

      Rails.cache.fetch('console-token', expires_in: (4.hours - 5.minutes)) do
        response.token
      end
    end

    def indentity_http_client
      @indentity_http_client ||= HttpClient.new(ENV['IUGU_BASE_URL'], jwt: Rails.cache.fetch('console-token'))
    end
  end
end
