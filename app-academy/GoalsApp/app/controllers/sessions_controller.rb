class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by_credentials(params[:user][:username], params[:user][:password])
    if @user.nil?
      redirect_to new_session_url
    else
      self.current_user = @user
      redirect_to goals_url
    end
  end

  def destroy

    self.logout_current_user!
    redirect_to new_session_url
  end
end

