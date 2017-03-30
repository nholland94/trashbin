class SubsController < ApplicationController
  def new
    @sub = Sub.new
    if !logged_in?
      add_flash(:errors, "You must be logged in to create a sub!")
      redirect_to new_user_url
    else
      render :new
    end
  end

  def create
    @sub = Sub.new(params[:sub])

    if @sub.save
      redirect_to sub_url(@sub.id)
    else
      add_flash(:errors, "Please try again.")
      redirect_to new_sub_url
    end
  end

  def edit
    @sub = Sub.find(params[:id])

    render :edit
  end

  def update
    @sub = Sub.find(params[:id])
    if @sub.update_attributes(params[:sub])
      redirect_to sub_url(@sub.id)
    else
      render :edit
    end
  end

  def show
    @sub = Sub.find(params[:id])

    render :show
  end

  def destroy
  end

end
