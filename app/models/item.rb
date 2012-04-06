class Item < ActiveRecord::Base
  has_and_belongs_to_many :availability_options
  has_many :avatars, :dependent => :destroy
  belongs_to :listing_type
  
  accepts_nested_attributes_for :avatars, :allow_destroy => true

  has_many :avatars, :dependent => :destroy
  


  belongs_to :user

  validates :address, :presence => true
  validates :listing_type_id, :presence => true
  validates :title, :presence => true
  validates :description, :presence => true
  validates :price, :presence => true
  validates :is_agree, :presence => true
  #  validates_format_of :phone, :allow_blank => true,
  #    :with => /^(1\s*[-\/\.]?)?(\((\d{3})\)|(\d{3}))\s*[-\/\.]?\s*(\d{3})\s*[-\/\.]?\s*(\d{4})\s*(([xX]|[eE][xX][tT])\.?\s*(\d+))*/
  #  validates_numericality_of :price, :only_integer => true, :message => "can only be whole number"
  
  
  
  def creator_id
    self.user_id.to_i
  end
end
