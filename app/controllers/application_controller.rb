# -*- encoding : utf-8 -*-
require 'utility'
require 'google'
require 'pp'
require 'net/http'
require 'uri'
require 'json'
require 'cgi'

class ApplicationController < ActionController::Base
  protect_from_forgery
  def available_locales; AVAILABLE_LOCALES; end
  helper :all
  before_filter :set_locale
  helper_method :account_verified
  helper_method :message_user
  helper_method :exchange_currency
  before_filter :currency_conversion
    
  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && !resource.is_active?
      sign_out resource
      flash[:notice] = nil
      flash[:error] = t(:not_active)
      root_path
    else
      super
      root_path
    end
  end
  
  def currency_conversion
    session[:curr] = params[:curr] if params[:curr]
    session[:curr] = "USD" if session[:curr].blank?
  end

  def exchange_currency(amount, currency)
    Money.new(amount * 100, currency).exchange_to(session[:curr])
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { :locale => I18n.locale }
  end

  def translate( text, to='en', from='no' )
    unless params[:locale].nil?
      unless to.nil?
        case params[:locale]
        when "en"
          to = params[:locale]
          from = "no"
        when "nb"
          to = params[:locale]
          from = "en"
        end
      end
    else
      to = "no"
    end
    base = 'http://ajax.googleapis.com/ajax/services/language/translate'
    # assemble query params
    params = {
      :langpair => "#{from}|#{to}",
      :q => text,
      :v => 1.0
    }
    query = params.map{ |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
    # send get request
    response = Net::HTTP.get_response( URI.parse( "#{base}?#{query}" ) )

    json = JSON.parse( response.body )

    if json['responseStatus'] == 200
      json['responseData']['translatedText']
    else
      text
    end
  end

  def account_verified(user)
    true
  end

  def authenticate_admin    
    if current_user.blank? || !current_user.admin?
      flash[:error] = t(:authorized)
      redirect_to "/"
    end    
  end
end