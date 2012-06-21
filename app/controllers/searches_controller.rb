class SearchesController < ApplicationController

  def search_home
  end

  def gatherings
    #    @sizes = Item.select("distinct(size)").where("size is not NULL").order("size ASC")
    @sizes = Item.select("distinct(price)").where("price is not NULL").order("price ASC")
    @start_size = @sizes.first
    @last_size = @sizes.last
    @users_with_uniq_cities = Item.select("distinct(city)").where("city is not NULL and city != ''")
    #    @users_with_uniq_cities = User.select("distinct(city)")
  end

  def members
    @users_with_uniq_cities = User.select("distinct(city)")
    @users_with_uniq_activites = User.select("distinct(activity)").where("activity is not NULL and activity != ''")
  end

  def search_gatherings
    conds = "1=1 "
    
    if params[:search][:location] && !params[:search][:location].blank?
      conds += "and (LOWER(city) LIKE " + "'%%" + params[:search][:location].strip.downcase.to_s+ "%%'" +")"
    end
       
    unless params[:min_size].blank?
      conds += " AND (price >= '#{params[:min_size]}')"
    end
    
    unless params[:max_size].blank?
      conds += " AND (price <= '#{params[:max_size]}')"
    end    
    #    conds += " and is_gathering = true and status != 'Applied'"
    @items = Item.find(:all,:conditions => [conds])
        
    @gatherings = []
    @items.each do|item|
      #      offers = item.offers.where("status = 'Applied' and persons_in_gathering > 0 and is_gathering = true and parent_id is NULL and rental_start_date <= '#{Date.parse("#{Date.today}","%Y-%d-%m")}' and rental_end_date >= '#{Date.parse("#{Date.today}","%Y-%d-%m")}'")      
      offers = item.offers.where("status = 'Applied' and persons_in_gathering > 0 and is_gathering = true and parent_id is NULL and rental_end_date >= '#{Date.parse("#{Date.today}","%Y-%d-%m")}'")
      offers.each do|offer|
        if !offer.members.include?(current_user) and offer.user != current_user
          @gatherings  << offer
        end
      end
    end
    unless @gatherings.blank?
      @gatherings = @gatherings.uniq
    end    
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
