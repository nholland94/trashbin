module NotesHelper
  def is_owner?
    note = Note.find(params[:id])
    unless current_user.id == note.user_id
      redirect_to track_url(note.track_id)
    end
  end
end
