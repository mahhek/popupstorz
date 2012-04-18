class UsersController < ApplicationController
  def show
    @user = User.find_by_id(params[:id])
  end
  
  def search_members
    conds = ""
    if params[:search][:location]
      conds += "(LOWER(city) LIKE " + "'%%" + params[:search][:location].strip.downcase.to_s+ "%%'" + "or LOWER(country) LIKE " + "'%%" +params[:search][:location].strip.downcase.to_s + "%%'" +")"
    end
    if params[:search][:type]
      if !conds.blank? and !params[:search][:type].blank?
        conds += " or "
      end
      unless params[:search][:type].blank?
        conds += "LOWER(activity) LIKE "+ "'%%" + params[:search][:type].strip.downcase.to_s + "%%'"
      end      
    end
    unless params[:search][:user].blank?
      unless conds.blank?
        conds += " or "
      end
      conds += "(LOWER(first_name) LIKE "+ "'%%"+ params[:search][:user].strip.downcase.to_s + "%%'" + " or LOWER(last_name) LIKE "  + "'%%" + params[:search][:user].strip.downcase.to_s + "%%'" +")"
    end
    @members = User.paginate(:page => params[:page], :per_page => 4, :conditions => [conds])
  end
  
  
end