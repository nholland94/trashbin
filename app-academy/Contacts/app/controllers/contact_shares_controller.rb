class ContactSharesController < ApplicationController
  def index
    @contact_shares = ContactShare.all
    render :json => @contact_shares
  end

  def create
    @contact_share = ContactShare.new(params[:contact_share])

    if @contact_share.save
      render :json => @contact_share
    else
      render :json => @contact_share.errors, :status => :unprocessable_entity
    end
  end

  def show
    @contact_share = ContactShare.find(params[:id])
    render :json => @contact_share
  end

  def update
    @contact_share = ContactShare.find(params[:id])
    if @contact_share.update_attributes(params[:contact_share])
      render :json => @contact_share
    else
      render :json => @contact_share.errors, :status => :unprocessable_entity
    end
  end

  def destroy
    @contact_share = ContactShare.find(params[:id])
    @contact_share.destroy

    redirect_to contact_shares_url
  end
end
