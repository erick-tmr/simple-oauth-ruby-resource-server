# frozen_string_literal: true

class ProtectedController < ApplicationController
  include JwtAuthenticated
end
