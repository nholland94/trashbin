class BandsController < ApplicationController
  def new
    @band = Band.new

    render :new
  end

  def create
    @band = Band.new(params["band"])

    if @band.save
      redirect_to band_url(@band.id)
    else
      add_flash(:errors, "could not create band")
      redirect_to new_band_url
    end
  end

  def edit
    @band = Band.find(params[:id])

    render :edit
  end

  def update
    @band = Band.find(params[:id])

    if @band.update_attributes(params["band"])
      redirect_to band_url(@band.id)
    else
      add_flash(:errors, "could not save band")
      redirect_to edit_band_url(params[:id])
    end
  end

  def index
    @bands = Band.all

    render :index
  end

  def show
    @band = Band.find(params[:id])

    render :show
  end

  def destroy
    @band = Band.find(params[:id])
    @band.destroy

    add_flash(:messages, "#{@band.name} has been disbanded!")
    redirect_to bands_url
  end
end
