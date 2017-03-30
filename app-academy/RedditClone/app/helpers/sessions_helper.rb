module SessionsHelper

  def current_user
    return nil unless session[:session_token]

    @current_user ||= User.find_by_session_token(session[:session_token])
  end

  def logged_in?
    !!self.current_user
  end

  def log_in_user!(user)
    session[:session_token] = user.reset_session_token!
  end

  def log_out!
    self.current_user.reset_session_token!
    session[:session_token] = nil
  end
end
