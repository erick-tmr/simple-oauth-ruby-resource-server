class SessionsController < ApplicationController
  layout 'sessions'

  def new
    redirect_to root_path and return if session[:user_id]
  end
end
