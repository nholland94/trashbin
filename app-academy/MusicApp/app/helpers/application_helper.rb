module ApplicationHelper
  def add_flash(type, message)
    flash[type] ||= []
    flash[type] << message
  end

  def require_admin!
    unless current_user && current_user.admin
      redirect_to bands_url
    end
  end
end
