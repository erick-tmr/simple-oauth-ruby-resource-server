# frozen_string_literal: true

class BarbecuesController < ProtectedController
  def index
    @barbecues = []
  end
end
