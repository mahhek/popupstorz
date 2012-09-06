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
      flash[:notice] = t(:created_email_setting)
      redirect_to :action => "show"
    else
      flash[:notice] = t(:email_setting_cant_save)
      redirect_to :action => "new"
    end
  end
  
  def edit
    @email_setting = current_user.email_setting
  end
  
  def update
    @email_setting = EmailSetting.find(params[:id])
    if @email_setting.update_attributes(params[:email_setting])
      flash[:notice] = t(:updating_email_setting)
      redirect_to :action => "show"
    else
      flash[:notice] = t(:email_setting_not_update)
      redirect_to :action => "edit"
    end
  end
  
end