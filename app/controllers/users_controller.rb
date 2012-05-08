class UsersController < ApplicationController
  
  def show
    @user = User.find_by_id(params[:id])
    @comment=Comment.new
  end
  
  def search_members
    conds = ""
    if params[:search][:location]
      conds += "(LOWER(city) LIKE " + "'%%" + params[:search][:location].strip.downcase.to_s+ "%%'" + "or LOWER(country) LIKE " + "'%%" +params[:search][:location].strip.downcase.to_s + "%%'" +")"
    end
    if params[:search][:type]
      if !conds.blank? and !params[:search][:type].blank?
        conds += " and "
      end
      unless params[:search][:type].blank?
        conds += "LOWER(activity) LIKE "+ "'%%" + params[:search][:type].strip.downcase.to_s + "%%'"
      end      
    end
    unless params[:search][:user].blank?
      unless conds.blank?
        conds += " and "
      end
      user = params[:search][:user].split(" ")
      if user[1].blank?
        conds += "(LOWER(first_name) LIKE "+ "'%%"+ user[0].strip.downcase.to_s + "%%'" + " or LOWER(last_name) LIKE "  + "'%%" + params[:search][:user].strip.downcase.to_s + "%%'"+ " or LOWER(email) LIKE "  + "'%%" + user[0].strip.downcase.to_s + "%%'" +")"
      else
        conds += "((LOWER(first_name) LIKE "+ "'%%"+ user[0].strip.downcase.to_s + "%%'" + " and LOWER(last_name) LIKE "  + "'%%" + user[1].strip.downcase.to_s + "%%'"+ ") or LOWER(email) LIKE "  + "'%%" +  params[:search][:user].strip.downcase.to_s + "%%'" +")"
      end
    end
    
    @members = User.find(:all, :conditions => [conds])
#    @members = User.paginate(:page => params[:page], :per_page => 4, :conditions => [conds])
  end
    def add_comment
    @comment = Comment.new(params[:comment])
    @comment.user=current_user
    @user =User.find(params[:id])
    if @comment.save
      flash[:notice] = "Comment Added"
      @user.comments << @comment
       redirect_to profile_path(current_user)
    else
      flash[:error] = "Not saved"
      render :show
    end

  end
  
  
end