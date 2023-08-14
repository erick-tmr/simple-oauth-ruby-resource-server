# frozen_string_literal: true

class WorkspacesController < ProtectedController
  def select
    session['current_workspace_id'] = params[:workspace_id]

    redirect_back fallback_location: root_path
  end
end
