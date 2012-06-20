class SearchesController < ApplicationController

  def search_home
  end

  def gatherings
    @users_with_uniq_cities = Item.select("distinct(city)").where("city is not NULL and city != ''")
#    @users_with_uniq_cities = User.select("distinct(city)")
  end

  def members
    @users_with_uniq_cities = User.select("distinct(city)")
    @users_with_uniq_activites = User.select("distinct(activity)").where("activity is not NULL and activity != ''")
  end

  def search_gatherings
    conds = ""
    if params[:search][:location]
      conds += "(LOWER(city) LIKE " + "'%%" + params[:search][:location].strip.downcase.to_s+ "%%'" +")"
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
#    conds += " and is_gathering = true and status != 'Applied'"
    @gatherings = Item.find(:all,:conditions => [conds])
    
#    @members = User.find(:all, :conditions => [conds])
    #    @members = User.paginate(:page => params[:page], :per_page => 4, :conditions => [conds])
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
end
