# -*- encoding : utf-8 -*-
require 'crack'
require 'uuidtools'

module Utility
  def self.parse_xml xml_string
    Crack::XML.parse xml_string
  end

  def self.get_new_uuid
    UUIDTools::UUID.random_create.to_s.upcase
  end
end
