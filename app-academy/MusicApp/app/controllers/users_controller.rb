class UsersController < ApplicationController
  before_filter :require_admin!, only: [:index]

  def index
    @users = User.all

    render :index
  end

  def show
    @user = User.find(params[:id])

    render :show
  end

  def new
    @user = User.new

    render :new
  end

  def create
    @user = User.new(params["user"])

    if @user.save
      add_flash(:messages, "New user created!")
      login!(@user)
      message = UserMailer.activation_email(@user)
      message.deliver!
      redirect_to user_url(@user.id)
    else
      add_flash(:errors, "could not create new user")
      add_flash(:errors, @user.errors)
      redirect_to signup_url
    end
  end

  def edit
    @user = User.find(params[:id])

    render :edit
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params["user"])
      add_flash[:messages, "Changes saved!"]
      redirect_to user_url(@user.id)
    else
      add_flash(:error, "could not save user")
      redirect_to edit_user(@user.id)
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_url
  end

  def activate
    @user = User.find_by_activation_token(params["activation_token"])

    if @user
      @user.activated = true
      @user.save
      add_flash(:messages, "You have been successfully activated")
      redirect_to user_url(@user.id)
    else
      redirect_to users_url
    end
  end
end
