class CommentsController < ApplicationController

  def create
    @comment = Comment.new(params[:comment])
    if @comment.save
      redirect_to link_url(@comment.link_id)
    elsif @comment.parent_comment_id.nil?
      redirect_to link_url(@comment.link_id)
    else
      redirect_to comment_url(@comment.parent_comment_id)
    end
  end

  def show
    @comment = Comment.find(params[:id])

    render :show
  end

  def vote
    @vote = UserCommentVote.new(params[:vote])

    if @vote.save
      redirect_to link_url(params[:link_id])
    else
      add_flash(:errors, "could not vote!")
      redirect_to link_url(params[:link_id])
    end
  end

end
