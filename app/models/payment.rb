# -*- encoding : utf-8 -*-
class Payment < ActiveRecord::Base
    PROCESSING, FAILED, SUCCESS, VERIFIED = 1, 2, 3, 4
  attr_accessible :stripe_card_token,:amount, :stripe_card_token, :seller_id, :renter_id,:rentareto_fee,:seller_amount,:offer_id
  validates :amount, :presence => true, :numericality => { :greater_than => 0 }
  belongs_to :offer

  def owner
    User.find_by_id(self.seller_id)
  end

  def renter
    User.find_by_id(self.renter_id)
  end

  def purchase(do_action)
    if do_action == "verify"
      self.status = PROCESSING
      unless customer.nil?
        self.stripe_customer_token = customer.id
        self.status = VERIFIED
      else
        self.status = FAILED
      end
    else do_action == "charge"
      self.status = PROCESSING
      charge = Stripe::Charge.create( :amount => self.amount.to_i * 100, :currency => "usd", :customer => self.stripe_customer_token )

      if charge.paid
        self.transaction_number = charge.id
        self.status = SUCCESS
      else
        self.status = FAILED
      end
    end
    return self
  end
end