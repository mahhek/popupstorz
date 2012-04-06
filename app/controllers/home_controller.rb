class HomeController < ApplicationController

  def index
    if !session[:items].blank?
      redirect_to new_item_path
    elsif !session[:item].blank?
      redirect_to new_item_offer_path(session[:item])
    elsif !session[:edit_item].blank?
      redirect_to edit_item_offer_path(session[:edit_item], session[:edit_offer])
    end
  end


  def about
    
  end
  
end
