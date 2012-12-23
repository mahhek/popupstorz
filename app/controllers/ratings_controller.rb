# -*- encoding : utf-8 -*-
class RatingsController < ApplicationController
  before_filter :authenticate_user!
  def rate
    
    @asset = eval(params[:class_name]).find(params[:id])
    unless current_user.admin
      
      @rating = Rating.find(:first, :conditions =>["rateable_id = ? and user_id = ? and rateable_type = ?",@asset.id,current_user.id,@asset.class.to_s])
    else
      @rating = Rating.find(:first, :conditions =>["rateable_id = ? and rateable_type = ?",@asset.id,@asset.class.to_s])
    end
    if @rating      
      @rating.update_attribute(:accuracy_rating, params[:accuracy_rating]) unless params[:accuracy_rating].blank?
      @rating.update_attribute(:commodities_rating, params[:commodities_rating]) unless params[:commodities_rating].blank?
      @rating.update_attribute(:location_rating, params[:location_rating]) unless params[:location_rating].blank?
      @rating.update_attribute(:seriousness_rating, params[:seriousness_rating]) unless params[:seriousness_rating].blank?
      @rating.update_attribute(:communication_rating, params[:communication_rating]) unless params[:communication_rating].blank?
      @rating.update_attribute(:value_rating, params[:value_rating]) unless params[:value_rating].blank?
    else
      @asset.add_rating(Rating.new(:accuracy_rating => params[:accuracy_rating], :user_id => current_user.id)) if params[:accuracy_rating]
      @asset.add_rating(Rating.new(:commodities_rating => params[:commodities_rating], :user_id => current_user.id)) if params[:commodities_rating]
      @asset.add_rating(Rating.new(:location_rating => params[:location_rating], :user_id => current_user.id)) if params[:location_rating]
      @asset.add_rating(Rating.new(:seriousness_rating => params[:seriousness_rating], :user_id => current_user.id)) if params[:seriousness_rating]
      @asset.add_rating(Rating.new(:communication_rating => params[:communication_rating], :user_id => current_user.id)) if params[:communication_rating]
      @asset.add_rating(Rating.new(:value_rating => params[:value_rating], :user_id => current_user.id)) if params[:value_rating]
    end
    respond_to do |format|
      format.js do
        if current_user.admin
          foo = render_to_string(:partial => 'admin/ratings/rating' , :locals=>{ :asset => @asset, :only_view =>  "false" }).to_json
        else
          foo = render_to_string(:partial => '/ratings/rating' , :locals=>{ :asset => @asset, :only_view =>  "false" }).to_json
        end
        if @asset.class.to_s == "User"
          render :js => "$('#rating_of_user_#{@asset.id}').html(#{foo});"
        elsif @asset.class.to_s == "Item"
          
          render :js => "$('#rating_of_item_#{@asset.id}').html(#{foo});"
        end
      end
    end
  end

end