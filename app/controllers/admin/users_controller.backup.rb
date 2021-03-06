# -*- encoding : utf-8 -*-
class Admin::UsersController < ApplicationController
  before_filter :authenticate_admin
  layout "admin"

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    
    @user=User.new(params[:user])
    @user.skip_confirmation!
    if @user.save
      UserMailer.send_user_information(@user).deliver

    end
    redirect_to admin_items_path
  end

  def show
    @user = User.find(params[:id])   
  end

  def destroy_user
    user = User.find(params[:id])
    user.update_attribute(:is_active, !user.is_active)
    redirect_to admin_users_path    
  end

  def all_messages
   
    @messages = ActsAsMessageable::Message.all

  end

  def delete_message
    
    @msg= ActsAsMessageable::Message.find_by_id(params[:id])
    @msg.destroy
    redirect_to all_messages_admin_users_path
  end

  def all_ratings
    @ratings = Rating.all
    
  end

  def delete_rating
    sdf
  end

end