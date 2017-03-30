class LinksController < ApplicationController
  include LinksHelper

  def new
    @link = Link.new
    @subs = Sub.all

    render :new
  end

  def create
    @link = Link.new(params[:link])

    if params[:sub_selection] && @link.save
      add_link_to_subs!
      redirect_to link_url(@link.id)
    else
      add_flash(:errors, "Please try again.")
      redirect_to new_link_url
    end
  end

  def edit
    @link = Link.find(params[:id])
    @subs = Sub.all

    render :edit
  end

  def update
    @link = Link.find(params[:id])
    if @link.update_attributes(params[:link])
      redirect_to link_url(@link.id)
    else
      render :edit
    end
  end

  def show
    @link = Link.find(params[:id])

    render :show
  end

  def destroy
  end

end
