# frozen_string_literal: true

module Api
  class BarbecuesController < Api::BaseController
    def index
      barbecues = Barbecue.all
    end

    def create
      barbecue = Barbecue.new
    end
  end
end
