class GoalsController < ApplicationController
  include GoalsHelper
  before_filter :require_logged_in!
  before_filter :require_owner_if_private!, :only => [:show]
  before_filter :require_owner!, :only => [:edit, :destroy, :update, :change_finished_state]

  def index
    @all_goals = Goal.all
    @all_goals.reject! { |goal| goal.is_private && goal.user != current_user }
  end

  def show
    @goal = Goal.find(params[:id])
  end

  def new
    @goal = Goal.new
  end

  def create
    @goal = Goal.new(params[:goal])
    if @goal.save
      redirect_to goal_url(@goal.id)
    else
      render :new
    end
  end

  def edit
    @goal = Goal.find(params[:id])
  end

  def update
    @goal = Goal.find(params[:id])
    if @goal.update_attributes(params[:goal])
      redirect_to goal_url(@goal.id)
    else
      render :edit
    end
  end

  def destroy
    @goal = Goal.find(params[:id])
    @goal.destroy
    redirect_to goals_url
  end

  def change_finished_state
    @goal = Goal.find(params[:id])
    @goal.update_attributes(finished: !@goal.finished)
    redirect_to user_url(@goal.user.id)
  end
end
