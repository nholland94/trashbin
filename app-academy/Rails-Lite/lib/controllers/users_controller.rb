class UserController < ControllerBase
  def index
    @users = User.all
    @users = [] if @users.nil?

    render :index
  end

  def new
    @user = User.new

    render :new
  end

  def create

  end
end