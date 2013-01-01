# -*- encoding : utf-8 -*-
class AvatarsController < ApplicationController
  before_filter :load_item
  def new
    if current_user.admin      
       @avatar = @item.avatars.build
      render :layout => "admin"
    else
      @avatar = @item.avatars.build
    end
  end

  def create
    upload_pics
    if current_user.admin
      return redirect_to admin_items_path
    else
      
      return redirect_to items_path
    end
  end

  def edit
    #    @item = Item.find(params[:id])
    @avatars = @item.avatars
    unless @avatars.blank?
      @avatar = @avatars.first
    else
      @avatar = Avatar.new
      #      @avatar = @item.avatars.build
    end
  end
  
  def update
    upload_pics
    return redirect_to items_path
  end
  
  def upload_pics
    (1..15).each do |a|
      unless params['photo_'+a.to_s].blank?
        params[:avatar][:photo] = params['photo_'+a.to_s]
        @avatar = @item.avatars.build(params[:avatar])
        @avatar.caption = "" if params[:avatar][:caption] == t(:photo_caption)
        if @avatar.save
          flash[:notice] = t(:photos_upload_success)
          #      @item.update_attribute("item_status", params[:item_status])
        else
          flash[:notice] = t(:cant_save_picture)
        end
      end
    end
  end

  def destroy
    @avatar = Avatar.find_by_id(params[:id])
    if @avatar.destroy
      return redirect_to new_item_avatar_path(@item)
    else
      flash[:notice] = t(:problem_deletin_picture)
      return render :action =>"new"
    end
  end

  protected
  def load_item
    @item = Item.find_by_id(params[:item_id])
  end
end