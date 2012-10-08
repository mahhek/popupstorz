class Admin::OffersController < ApplicationController
  before_filter :authenticate_admin
  layout "admin"
  def index
    @offers = Offer.all(:conditions => ["status != 'Cancelled' and parent_id is NULL and is_gathering = false and persons_in_gathering is NULL "])
  end
  
  def gatherings
    @offers = Offer.all(:conditions => ["status != 'Cancelled' and parent_id is NULL and is_gathering = true and persons_in_gathering > 0 "])
  end

  def change_commission_rate    
    @offer = Offer.find_by_id(params[:offer_id])
    @offer.commission_rate = params[:commision_rate].to_i
    @offer.save
    redirect_to admin_offers_path
  end
end