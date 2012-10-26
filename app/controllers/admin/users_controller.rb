# -*- encoding : utf-8 -*-
class Admin::UsersController < ApplicationController
  before_filter :authenticate_admin
  layout "admin"

  def index
    case params[:sort_option]
    when "1"
      order_by = "created_at DESC"
    when "2"
      order_by = "created_at ASC"
    when "3"
      order_by = "activity ASC"
    when "4"
      order_by = "gender DESC"
    when "5"
      order_by = "city ASC"
    when "6"
      order_by = "country ASC"
    when "7"
      order_by = "show_fb_info"
    when "8"
      order_by = "last_name ASC"
    else
      order_by = "created_at DESC"
    end
    @users = User.all(:order => order_by)
    respond_to do |format|
      format.js do
        foo = render_to_string(:partial => 'users', :locals => { :users => @users }).to_json
        render :js => "$('#users_list').html(#{foo});"
      end
      format.html
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.skip_confirmation!
    if @user.save
      UserMailer.send_user_information(@user).deliver
      redirect_to admin_users_path
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    params[:user][:verify_email] = params[:user][:email]
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    if @user.update_attributes(params[:user])
      flash[:notice] = "User updated successfully!"
      redirect_to admin_users_path
    else
      flash[:error] = "User can't be updated. Please try again or later!"
      render :edit
    end    
  end

  def destroy_user
    user = User.find(params[:id])
    user.update_attribute(:is_active, !user.is_active)
    redirect_to admin_users_path
  end


  def all_messages
    case params[:sort_option]
    when "1"      
      order_by = "created_at DESC"
    when "2"
      order_by = "received_messageable_id ASC"
    when "3"
      order_by = "received_messageable_type ASC"
    else
      order_by = "created_at ASC"
    end    
    @messages = ActsAsMessageable::Message.all(:order => order_by)
    respond_to do |format|
      format.js do
        foo = render_to_string(:partial => 'messages', :locals => {:messages => @messages }).to_json
        render :js => "$('#admin_messages_list').html(#{foo});"
      end
      format.html
    end    
  end

  def delete_message
    #    @messages = ActsAsMessageable::Message.all
    @msg= ActsAsMessageable::Message.find_by_id(params[:id])
    @msg.destroy
    redirect_to all_messages_admin_users_path
  end

  def all_feedbacks
    @comments = Comment.all
  end
  
  def all_ratings
    @ratings = Rating.all
  end

  def delete_rating
    @rating = Rating.find_by_id(params[:id])
    @rating.destroy
    redirect_to all_ratings_admin_users_path
  end
  
  def delete_rating
    @comment = Comment.find_by_id(params[:id])
    @comment.destroy
    redirect_to all_comments_admin_users_path
  end

  def send_invitation
    (1..10).each do |i|
      unless params["email"+"#{i}"].blank?
        @invitation = Invitation.new
        @invitation.user = current_user
        @invitation.email = params["email"+"#{i}"]
        @invitation.token = (Digest::MD5.hexdigest "#{ActiveSupport::SecureRandom.hex(10)}-#{DateTime.now.to_s}")
        @invitation.save
        UserMailer.send_admin_invitation_email(@invitation,params["fname"+"#{i}"],params["lname"+"#{i}"],params[:message]).deliver
      end
    end
    flash[:notice] = t(:invitation_sent)
    redirect_to admin_users_path
  end

  #  def send_invitation_to_users
  #    unless params[:user].blank?
  #      params[:user][0].split(',').each do |val|
  #        unless val.blank?
  #          @invitation = Invitation.new
  #          @invitation.user = current_user
  #          @invitation.email = val
  #          @invitation.token = (Digest::MD5.hexdigest "#{ActiveSupport::SecureRandom.hex(10)}-#{DateTime.now.to_s}")
  #          @invitation.save
  #          UserMailer.send_invitation_email(@invitation).deliver
  #        end
  #      end
  #    end    
  #    redirect_to admin_items_path
  #  end

  def all_payments
    @payments = Payment.all
  end

  def cancel_payment
    @payment = Payment.find_by_id(params[:id])
    @payment.update_attribute(:cancelled_at, date.today)
    @payment.update_attribute(:is_active, !user.is_active)
    redirect_to all_payments_admin_users_path
  end
  
  #  def send_invitations
  #    (1..10).each do |i|
  #      unless params["email"+"#{i}"].blank?
  #        @invitation = Invitation.new
  #        @invitation.user = current_user      
  #        @invitation.email = params["email"+"#{i}"]
  #        @invitation.token = (Digest::MD5.hexdigest "#{ActiveSupport::SecureRandom.hex(10)}-#{DateTime.now.to_s}")
  #        @invitation.save
  #        UserMailer.send_admin_invitation_email(@invitation,params[:additional_message]).deliver
  #      end
  #    end
  #    flash[:notice] = t(:invitation_sent)
  #    redirect_to admin_users_path
  #  end
  
end