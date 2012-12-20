# -*- encoding : utf-8 -*-
module ApplicationHelper

  def exchange_currency(amount, currency)
    Money.new(amount * 100, currency).exchange_to(session[:curr])
  end
  
  def nl2br(s)
    unless s.blank?
      s.gsub(/\n/, '<br>')
    else
      s
    end    
  end
  
end