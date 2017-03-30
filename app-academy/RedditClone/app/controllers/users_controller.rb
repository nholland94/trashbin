class UsersController < ApplicationController
  def new
    @user = User.new

    render :new
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      log_in_user!(@user)
      redirect_to user_url(@user.id)
    else
      add_flash(:errors, "could not create user")
      redirect_to new_user_url
    end
  end

  def edit
    @user = User.find(params[:id])

    render :edit
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to user_url(@user.id)
    else
      render :edit
    end
  end

  def show
    @user = User.find(params[:id])

    render :show
  end

  def destroy
  end

end
