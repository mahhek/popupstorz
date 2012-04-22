module ApplicationHelper

  def exchange_currency(amount)
    amount.to_money.exchange_to(session[:curr])
  end
  
end
