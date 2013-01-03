# -*- encoding : utf-8 -*-
class Avatar < ActiveRecord::Base
  belongs_to :item
  belongs_to :user

  has_attached_file :photo,
#    :storage => :filesystem, :path => ":rails_root/public/:class/:attachment/:id/:basename.:extension",
    :storage => 's3',
    :s3_credentials => {:access_key_id => "AKIAIETPPQ55S3QZGFQA" ,:secret_access_key => "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"},
    :bucket => "rentareto",
    :path => "/system/ugc/:class/:id/:style/:basename.:extension",
    :styles => {:thumb => "225X225#", :small => "96X72>", :medium => "240x180>", :large => "480x360#",:home => "266X177#" },
    :default_style => :original
#  :styles => {:thumb => "225X225#" }
end