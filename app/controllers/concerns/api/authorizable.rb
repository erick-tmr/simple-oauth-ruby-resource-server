# frozen_string_literal: true

module Api
  module Authorizable
    extend ActiveSupport::Concern

    include Oauth2Clientable

    included do
      before_action :refresh_console_token
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
