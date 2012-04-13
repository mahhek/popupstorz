class Admin::UsersController < ApplicationController
  before_filter :authenticate_admin
  layout "admin"

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    
  end
end
