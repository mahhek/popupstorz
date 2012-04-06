class Avatar < ActiveRecord::Base
  belongs_to :item
  belongs_to :user

  has_attached_file :photo,

    :storage => 's3',
    :s3_credentials => {:access_key_id => "AKIAIETPPQ55S3QZGFQA" ,:secret_access_key => "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"},
    :bucket => "rentareto",
    :path => "/system/ugc/:class/:id/:style/:basename.:extension",
    :styles => {:thumb => "125x125>", :small => "150x150>", :medium => "275x275>", :large => "400x400>" },
    :default_style => :original



  #  validates_attachment_presence :photo
  #  validates_attachment_size :photo, :less_than => 5.megabytes
  #  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'image/jpg', 'image/bmp']
end


