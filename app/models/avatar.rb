# -*- encoding : utf-8 -*-
class Avatar < ActiveRecord::Base
  belongs_to :item
  belongs_to :user

  has_attached_file :photo,
    :storage => 's3',
    :s3_credentials => {:access_key_id => "AKIAIETPPQ55S3QZGFQA" ,:secret_access_key => "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"},
    :bucket => "rentareto",
    :path => "/system/ugc/:class/:id/:style/:basename.:extension",
    :styles => {:thumb => "125x125>", :small => "96X72", :medium => "240x180>", :large => "480x360>" },
    :default_style => :original
end


