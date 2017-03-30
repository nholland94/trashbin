class SessionsController < ApplicationController
  def new
    @user = User.new

    render "login"
  end

  def create
    @user = User.find_by_credentials(
      params["user"]["email"],
      params["user"]["password"]
    )

    if @user
      login!(@user)
      add_flash(:messages, "Logged in!")
      add_flash(:debug, "#{@user}")
      redirect_to users_url
    else
      add_flash(:errors, "incorrect name or password")
      redirect_to login_url
    end
  end

  def destroy
    logout!
    redirect_to users_url
  end
end
