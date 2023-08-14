# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    include JwtAuthenticated
    include Authorizable
  end
end
