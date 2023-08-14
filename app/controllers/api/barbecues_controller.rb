# frozen_string_literal: true

module Api
  class BarbecuesController < Api::BaseController
    def index
      authorize_action('churrasco:barbecues.list', params[:workspace_id])

      return render json: { error: 'Not authorize to execute churrasco:barbecues.list' } unless @authorized

      barbecues = Barbecue.where(workspace_id: params[:workspace_id])
      render json: { barbecues: }
    end

    def create
      authorize_action('churrasco:barbecues.create', params[:workspace_id])

      barbecue = Barbecue.new
    end
  end
end
