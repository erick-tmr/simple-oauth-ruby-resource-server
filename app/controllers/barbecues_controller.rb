# frozen_string_literal: true

class BarbecuesController < ProtectedController
  def index
    authorize_action('churrasco:barbecues.list', @workspace['id'], session[:user_subject])

    @barbecues = Barbecue.where(workspace_id: @workspace['id'], owner: @user)
  end

  def new
    authorize_action('churrasco:barbecues.create', @workspace['id'], session[:user_subject])

    return redirect_back fallback_location: root_path, alert: 'Not Authorized to Create Barbecue' unless @authorized

    @barbecue = Barbecue.new
  end

  def create
    authorize_action('churrasco:barbecues.create', @workspace['id'], session[:user_subject])

    return redirect_back fallback_location: root_path, alert: 'Not Authorized to Create Barbecue' unless @authorized

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
