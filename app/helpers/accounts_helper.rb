# -*- encoding : utf-8 -*-
module AccountsHelper
  
  def number_to_currency(number, options = {})
    options[:locale] ||= I18n.locale
    super(number, options)
  end
  
end
