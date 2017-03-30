class NotesController < ApplicationController
  include NotesHelper
  before_filter :logged_in?
  before_filter :is_owner?, only: [:edit, :update, :destroy]

  def new
    @note = Note.new

    render :new
  end

  def create
    @note = Note.new(params["note"])

    if @note.save
      redirect_to track_url(@note.track_id)
    else
      add_flash(:errors, "could not create note")
      redirect_to new_track_note_url
    end
  end

  def edit
    @note = Note.find(params[:id])
  end

  def update
    @note = Note.find(params[:id])

    if @note.update_attributes(params["note"])
      redirect_to track_url(@note.track_id)
    else
      add_flash(:errors, "could not save note")
      redirect_to edit_note_url(params[:id])
    end
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy

    add_flash(:message, "Note burned!")
    redirect_to track_url(@note.track_id)
  end
end
