# -*- encoding : utf-8 -*-
class EmailSettingsController < ApplicationController
  
  before_filter :authenticate_user!, :except => [:index]
  
  def index
    @email_setting = current_user.email_setting
    if @email_setting.blank?
      redirect_to :action => "new"
    else
      redirect_to :action => "show"
    end
  end
  
  def show
    @email_setting = current_user.email_setting
  end
  
  def new
    @email_setting = EmailSetting.new
  end
  
  def create
    params[:email_setting][:user_id] = current_user.id    
    @email_setting = EmailSetting.new(params[:email_setting])
    if @email_setting.save
      flash[:notice] = "Thanks for creating your Email Settings."
      redirect_to :action => "show"
    else
      flash[:notice] = "Email Settings can't be saved right now. Please try again or later."
      redirect_to :action => "new"
    end
  end
  
  def edit
    @email_setting = current_user.email_setting
  end
  
  def update
    @email_setting = EmailSetting.find(params[:id])
    if @email_setting.update_attributes(params[:email_setting])
      flash[:notice] = "Thanks for updating your Email Settings."
      redirect_to :action => "show"
    else
      flash[:notice] = "Can't update your Email Settings right now. Please try again or later!"
      redirect_to :action => "edit"
    end
  end
  
end