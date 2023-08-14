# frozen_string_literal: true

class BarbecuesController < ProtectedController
  def index
    @barbecues = Barbecue.where(workspace_id: @workspace['id'], owner: @user)
  end

  def new
    @barbecue = Barbecue.new
    @workspace_options = @workspaces.map do |workspace|
      [workspace['name'], workspace['id']]
    end
  end

  def create
    create_params = barbecue_params.merge(owner: @user)
    @barbecue = Barbecue.new(create_params)

    if @barbecue.save
      redirect_to barbecues_path
    else
      render :new, alert: 'Error Saving Barbecue'
    end
  end

  def barbecue_params
    params.require(:barbecue).permit(:name, :workspace_id)
  end
end
