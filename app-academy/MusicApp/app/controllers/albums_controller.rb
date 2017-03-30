class AlbumsController < ApplicationController
  def new
    @album = Album.new
    @album.artist_id = params[:band_id]

    render :new
  end

  def create
    @album = Album.new(params["album"])

    if @album.save
      redirect_to album_url(@album.id)
    else
      add_flash(:errors, "could not create album")
      redirect_to new_band_album_url
    end
  end

  def edit
    @album = Album.find(params[:id])

    render :edit
  end

  def update
    @album = Album.find(params[:id])

    if @album.update_attributes(params["album"])
      redirect_to album_url(@album.id)
    else
      add_flash(:errors, "could not save album")
      redirect_to edit_album_url
    end
  end

  def index
    @albums = Band.find(params[:band_id]).albums

    render :index
  end

  def show
    @album = Album.find(params[:id])

    render :show
  end

  def destroy
    @album = Album.find(params[:id])
    @album.destroy

    add_flash(:messages, "#{@album.title} has been scratched!")
    redirect_to band_albums_url(@album.artist_id)
  end
end
