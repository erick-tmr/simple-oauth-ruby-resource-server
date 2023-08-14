# frozen_string_literal: true

module Api
  module JwtAuthenticated
    extend ActiveSupport::Concern
    include JwtValidatable

    included do
      rescue_from(*JwtValidatable::JWT_ERRORS, with: :jwt_error_response)
    end

    private

    def jwt_error_response
      @jwt
    end
  end
end
