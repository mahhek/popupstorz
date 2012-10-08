class Admin::MessagesController < ApplicationController
  layout "admin"
  def send_to_all
  
  end

  def send_message_to_all
    @users= User.all
    @users.each do |user|
      
      current_user.send_message(user, :topic => "from admin",:body => params[:body].html_safe)

    end
    flash[:alert]= "Your message has been sent to all users!"
    redirect_to admin_items_path
  end

  def send_message
    @user = User.find_by_id(params[:user_id])
  end

  def send_message_to_user
    @user = User.find_by_id(params[:user_id])
    current_user.send_message(@user, :topic => "from admin",:body => params[:body].html_safe)
    flash[:alert]= "Your message has been sent!"
    redirect_to admin_users_path
  end
  
end
