# frozen_string_literal: true

class SessionsController < ApplicationController
  layout 'sessions'

  def new
    redirect_to root_path and return if session[:user_id]
  end

  def destroy
    session.delete(:user_id)

    redirect_to new_session_path, notice: 'Logged out successfully'
  end
end
