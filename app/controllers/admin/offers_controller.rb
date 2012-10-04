class Admin::OffersController < ApplicationController
  before_filter :authenticate_admin
  layout "admin"
  def index
    @offers = Offer.all
  end

  def change_commission_rate    
    @offer = Offer.find_by_id(params[:offer_id])
    @offer.commission_rate = params[:commision_rate].to_i
    @offer.save
    redirect_to admin_offers_path
  end
end
