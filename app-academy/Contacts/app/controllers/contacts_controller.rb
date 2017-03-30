class ContactsController < ApplicationController
  def index
    @contacts = Contact.contacts_for_user_id(params[:user_id])

    render :json => @contacts
  end

  def index_all
    @contacts = Contact.all

    render :json => @contacts
  end

  def create
    # params[:contact][:user_id] = params[:user_id]
    contact_hash = params[:contact]
    contact_hash[:user_id] = params[:user_id]

    @contact = Contact.new(contact_hash)
    if @contact.save
      render :json => @contact
    else
      render :json => @contact.errors, :status => :unprocessable_entity
    end
  end

  def show
    @contact = Contact.find(params[:id])

    render :json => @contact
  end

  def update
    @contact = Contact.find(params[:id])

    if @contact.update_attributes(params[:contact])
      render :json => @contact
    else
      render :json => @contact.errors, :status => :unprocessable_entity
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    user_id = @contact.user_id

    @contact.destroy
    # redirect_to user_contacts_url(@contact.user_id)
    redirect_to "/users/#{user_id}/contacts"
  end
end
