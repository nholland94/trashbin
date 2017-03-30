class TracksController < ApplicationController
  def new
    @track = Track.new
    @track.album_id = params[:album_id]

    render :new
  end

  def create
    @track = Track.new(params["track"])

    if @track.save
      redirect_to track_url(@track.id)
    else
      add_flash(:errors, "could not create track")
      redirect_to new_album_track_url
    end
  end

  def edit
    @track = Track.find(params[:id])

    render :edit
  end
  
  def update
    @track = Track.find(params[:id])

    if @track.update_attributes(params["track"])
      redirect_to track_url(@track.id)
    else
      add_flash(:errors, "could not save track")
      redirect_to edit_track_url
    end
  end

  def index
    @tracks = Album.find(params[:album_id])

    render :index
  end

  def show
    @track = Track.find(params[:id])

    render :show
  end

  def destroy
    @track = Track.find(params[:id])
    @track.destroy

    add_flash(:messages, "A time machine was used to unwrite #{@track.title}")
    redirect_to album_track_url(@track.album_id)
  end
end
