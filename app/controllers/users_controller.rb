# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  
  def add_comment
    @comment = Comment.new(params[:comment])
    @comment.user=current_user
    @user =User.find(params[:id])
    if @comment.save
      flash[:notice] = "Comment Added"
      @user.comments << @comment
      redirect_to profile_path(current_user)
    else
      flash[:error] = "Not saved"
      render :show
    end

  end

  def show
    @user = User.find_by_id(params[:id])
  end
    
end