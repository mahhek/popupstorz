# -*- encoding : utf-8 -*-
class RegistrationsController < Devise::RegistrationsController  
  def new
    unless session[:fb_user].blank?
      @pre_user = User.find(session[:fb_user])
    end
    super
  end
  
  def create
    unless session[:fb_user].blank?
      @pre_user = User.find(session[:fb_user])
      education = @pre_user.studied_at
      works_at = @pre_user.works_at
      fb_pic_url = @pre_user.fb_pic_url
      fb_friends_count = @pre_user.fb_friends_count
      fb_pages = @pre_user.fb_pages
    end
    unless @pre_user.blank?
      @pre_user.destroy
      service = Service.find(:first, :conditions => ["user_id = ? and provider = 'facebook'",@pre_user.id])
    end
    super
    unless session[:fb_user].blank?
      @user.update_attributes({:studied_at => education, :works_at => works_at, :fb_pic_url => fb_pic_url, :fb_friends_count => fb_friends_count, :fb_pages => fb_pages,:is_active => true} )
    end
    unless @pre_user.blank?
      service.update_attribute("user_id",@user.id)
    end
    session[:fb_user] = ""
  end
  
  protected
  def after_update_path_for(resource)
    profile_path(resource.id)
  end
end