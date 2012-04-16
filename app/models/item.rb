
include Geokit::Geocoders


class Item < ActiveRecord::Base
  has_and_belongs_to_many :availability_options
  has_many :avatars, :dependent => :destroy
  belongs_to :listing_type
  
  accepts_nested_attributes_for :avatars, :allow_destroy => true

  has_many :avatars, :dependent => :destroy
  belongs_to :country
  before_save :geolocate_from_address

  belongs_to :user
  belongs_to :admin

  validates :address, :presence => true
  validates :listing_type_id, :presence => true
  validates :title, :presence => true
  validates :description, :presence => true
  validates :price, :presence => true
  #  validates :is_agree, :presence => true
  #  validates_format_of :phone, :allow_blank => true,
  #  :with => /^(1\s*[-\/\.]?)?(\((\d{3})\)|(\d{3}))\s*[-\/\.]?\s*(\d{3})\s*[-\/\.]?\s*(\d{4})\s*(([xX]|[eE][xX][tT])\.?\s*(\d+))*/
  #  validates_numericality_of :price, :only_integer => true, :message => "can only be whole number"
  
  belongs_to :locatable, :polymorphic => true
  
  def creator_id
    self.user_id.to_i
  end

  def geolocate_from_address

    # check if address has changed
    if self.address_changed?
      # check if an actual address has been set
      if self.address.to_s.strip.size > 0
        # find information related to address
        res = GoogleGeocoder.geocode(self.address)
        if(res)          
          self.city = res.city
          self.county = res.province
          self.country_code = res.country_code
          self.region = res.state
          self.zipcode = res.zip
          self.street = res.street_address
          self.latitude = res.lat
          self.longitude = res.lng
          self.street_name = res.street_name
          self.street_number = res.street_number
        else          
          # address not found
          self.city = nil
          self.county = nil
          self.country_code = nil
          self.region = nil
          self.zipcode = nil
          self.street = nil
          self.latitude = nil
          self.longitude = nil
        end
      end
    end
  end


end
