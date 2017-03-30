class UsersController < ApplicationController
  before_filter :require_logged_in!, :only => [:show]

  def new
    @user = User.new
    render :new
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      self.current_user = @user
      redirect_to goals_url
    else
      redirect_to new_user_url
    end
  end

  def show
    @user = User.find(params[:id])
  end
end
