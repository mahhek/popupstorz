# -*- encoding : utf-8 -*-
class Admin::UsersController < ApplicationController
  before_filter :authenticate_admin
  layout "admin"

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])   
  end

  def destroy_user
    user = User.find(params[:id])
    if user.destroy
      flash[:notice] = t(:user_deleted)
    else
      flash[:notice] = t(:cant_delete_user)
    end
    redirect_to admin_users_path
    
  end

end
