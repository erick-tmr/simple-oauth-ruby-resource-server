# frozen_string_literal: true

module Api
  module JwtAuthenticated
    extend ActiveSupport::Concern
    include JwtValidatable

    included do
      before_action :authenticate_jwt

      rescue_from(*JwtValidatable::JWT_ERRORS, with: :jwt_error_response)
    end

    private

    def authenticate_jwt
      @token = validate_jwt(bearer_token)
    end

    def jwt_error_response(error)
      render json: { error: "JWT error, #{error.class.name}, #{error.message}" }
    end

    def bearer_token
      pattern = /^Bearer /
      header  = request.headers['Authorization']
      header.gsub(pattern, '') if header&.match(pattern)
    end
  end
end
