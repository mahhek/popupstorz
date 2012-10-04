# -*- encoding : utf-8 -*-
class AccountsController < ApplicationController

  def dashboard
    @notifications = current_user.notifications
    @notifications.update_all(:is_read => true)
  end

  def new
    @account = Account.find_by_user_id(current_user.id)
  end

  def verification_selection
    respond_to do |format|
      format.js do
        @account = Account.find_by_id(params[:account_id])
        render_page_according_to_verification_type(params[:verification_type])
      end
    end
  end

  def update
    @account = Account.find_by_id(params[:id])
    case params[:verification_type]
    when "cc"
      do_cc_verification
    end
    redirect_to new_account_path
  end

  def render_page_according_to_verification_type(verification_type)
    case verification_type
    when "sms"
      if @account.is_sms_verified
        foo = ("<h2>#{t(:verified_sms)}</h2>").to_json
      else
        foo = render_to_string(:partial => '/accounts/sms_verify', :locals => { :account => @account }).to_json
      end
      render :js => "$('#verification_div').html(#{foo})"
    when "picture"
      if @account.is_picture_verified
        foo = ("<h2>#{t(:verified_picture)}</h2>").to_json
      else
        foo = render_to_string(:partial => '/accounts/picture_verify', :locals => { :account => @account }).to_json
      end
      render :js => "$('#verification_div').html(#{foo})"
    when "cc"
      if @account.is_cc_verified
        foo = ("<h2>#{t(:verified_card)}</h2>").to_json
      else
        foo = render_to_string(:partial => '/accounts/credit_card_verify', :locals => { :account => @account }).to_json
      end
      render :js => "$('#verification_div').html(#{foo})"
    when "facebook"
      if @account.is_facebook_verified
        foo = ("<h2>#{t(:verified_facebook)}</h2>").to_json
      else
        foo = render_to_string(:partial => '/accounts/facebook_verify', :locals => { :account => @account }).to_json
      end
      render :js => "$('#verification_div').html(#{foo})"
    when "linkedin"
      if @account.is_linkedin_verified
        foo = ("<h2>#{t(:verified_linkedin)}</h2>").to_json
      else
        foo = render_to_string(:partial => '/accounts/linkedin_verify', :locals => { :account => @account }).to_json
      end
      render :js => "$('#verification_div').html(#{foo})"
    when "twitter"
      if @account.is_twitter_verified
        foo = ("<h2>#{t(:verified_twitter)}</h2>").to_json
      else
        foo = render_to_string(:partial => '/accounts/twitter_verify', :locals => { :account => @account }).to_json
      end
      render :js => "$('#verification_div').html(#{foo})"
    end
  end

  def do_cc_verification
    unless params[:account][:stripe_card_token].blank?
      @account.update_attribute("stripe_card_token",params[:account][:stripe_card_token])
      @account.update_attribute("is_cc_verified",true)
      flash[:notice] = t(:card_verified)
    end
  end
  
end
