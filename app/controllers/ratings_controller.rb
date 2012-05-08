class RatingsController < ApplicationController
  before_filter :authenticate_user!


  def rate
    @asset = eval(params[:class_name]).find(params[:id])
    @rating = Rating.find(:first, :conditions =>["rateable_id = ? and user_id = ? and rateable_type = ?",@asset.id,current_user.id,@asset.class.to_s])
    if @rating
      @rating.update_attributes(:rating => params[:rating], :user_id => current_user.id)
    else
      @asset.add_rating(Rating.new(:rating => params[:rating], :user_id => current_user.id))
    end

    respond_to do |format|
      format.js do
        foo = render_to_string(:partial => '/ratings/rating' , :locals=>{ :asset => @asset }).to_json
        if @asset.class.to_s == "User"
          render :js => "$('#rating_of_user_#{@asset.id}').html(#{foo});"
        elsif @asset.class.to_s == "Item"
          render :js => "$('#rating_of_item_#{@asset.id}').html(#{foo});"
        end
      end
    end
  end
end
