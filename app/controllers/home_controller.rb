# -*- encoding : utf-8 -*-
class HomeController < ApplicationController
  def index
    session[:fb_user] = ""
#    if current_user && current_user.admin?
##      redirect_to admin_items_path
##        root_path
#    else
      if !session[:items].blank?
        redirect_to new_item_path
      elsif !session[:item].blank?
        redirect_to new_item_offer_path(session[:item])
      elsif !session[:edit_item].blank?
        redirect_to edit_item_offer_path(session[:edit_item], session[:edit_offer])
      end
      session[:start_date] = nil
      session[:end_date] = nil
      @items_with_uniq_cities = Item.select("distinct(city)")
      @items = Item.all(:limit => 10)
      active_items = []
      @items.each do|item|
        if item.user.is_active == true && item.display_on_home == true && item.is_active == true
          active_items << item
        end
      end
      @items = active_items
#    end
  end
  
  def send_feedback
    UserMailer.send_feedback(params[:feedback]).deliver
    flash[:notice] = t(:feedback_sent)
    redirect_to "/"   
  end
end