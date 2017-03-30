module LinksHelper
  def add_link_to_subs!
    params[:sub_selection].keys.each do |key|
      LinkSub.create(link_id: @link.id, sub_id: key.to_i)
    end
    nil
  end
end