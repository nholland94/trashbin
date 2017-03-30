module GoalsHelper

  def require_owner!
    redirect_to goals_url unless Goal.find(params[:id]).user == current_user
  end

  def require_owner_if_private!
    goal = Goal.find(params[:id])
    if goal.is_private
      redirect_to goals_url unless (goal.user == current_user)
    end
  end

end
