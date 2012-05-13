# -*- encoding : utf-8 -*-
require 'iconv'
module ExtendedString
  # Remove the accents from the string. Uses String::ACCENTS_MAPPING as the source map.
  def removeaccents
    self.chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s
  end

  # Fix charset using Iconv library
  def z_fix_charset
    Iconv.iconv('UTF-8', 'UTF-8', self).first.to_s
  end
  
  
  # Convert a string to a format suitable for a URL without ever using escaped characters.
  # It calls strip, removeaccents, downcase (optional) then removes the spaces (optional)
  # and finally removes any characters matching the default regexp (/[^-_A-Za-z0-9]/).
  #
  # Options
  #
  # * :downcase => call downcase on the string (defaults to true)
  # * :convert_spaces => Convert space to underscore (defaults to false)
  # * :regexp => The regexp matching characters that will be converting to an empty string (defaults to /[^-_A-Za-z0-9]/)
  def urlize(options = {})
    options[:downcase] ||= true
    options[:convert_spaces] ||= false
    options[:regexp] ||= /[^-_A-Za-z0-9]/
    
    str = self.strip.removeaccents
    str.downcase! if options[:downcase]
    str.gsub!(/\ /,'_') if options[:convert_spaces]
    str.gsub(options[:regexp], '')
  end
end
String.send :include, ExtendedString
