class SearchesController < ApplicationController

  def search_home
  end

  def gatherings
    #    #    @sizes = Item.select("distinct(size)").where("size is not NULL").order("size ASC")
    #    @sizes = Item.select("distinct(price)").where("price is not NULL").order("price ASC")
    @sizes = Offer.select("distinct(gathering_rental_price)").where("gathering_rental_price is not NULL").order("gathering_rental_price ASC")
    @start_size = @sizes.first
    @last_size = @sizes.last
    @last_price = @last_size.gathering_rental_price.to_f > 10000 ? @last_size.gathering_rental_price : 10000
    
    @users_with_uniq_cities = Item.select("distinct(city)").where("city is not NULL and city != ''")
    #    @users_with_uniq_cities = User.select("distinct(city)")
  end

  def members
    @users_with_uniq_cities = User.select("distinct(city)")
    @users_with_uniq_activites = User.select("distinct(activity)").where("activity is not NULL and activity != ''")
  end

  def search_gatherings
    conds = "1=1 "
    cities = []
    items = ""
    if params[:search][:location] && !params[:search][:location].blank?
      city_conds = "(LOWER(city) LIKE " + "'%%" + params[:search][:location].strip.downcase.to_s+ "%%'" +")"
      sel_items = Item.find(:all, :conditions => [ city_conds ])      
      count = 1
      sel_items.each do|item|
        if count != 1
          items = items +","+ "#{item.id.to_s}"
        else
          items += item.id.to_s
        end
        count += 1
      end
#      conds += "and (LOWER(city) LIKE " + "'%%" + params[:search][:location].strip.downcase.to_s+ "%%'" +")"
    end
  
    unless params[:min_size].blank?
      conds += " AND (gathering_rental_price >= '#{params[:min_size]}')"
    end
    
    unless params[:max_size].blank?
      conds += " AND (gathering_rental_price <= '#{params[:max_size]}')"
    end
    
    unless sel_items.blank?
      conds += " AND item_id in(#{items})"
    end
    
    
    conds += "AND (status NOT LIKE '%%Confirmed%%' and status != 'Cancelled') and persons_in_gathering > 0 and is_gathering = true and parent_id is NULL and rental_end_date >= '#{Date.parse("#{Date.today}","%Y-%d-%m")}'"
    
    
    @offers = Offer.find(:all,:conditions => [conds])

    unless @offers.blank?
      @offers = @offers.uniq
    end
    
    @offers = @offers.sort_by{|e| e[:gathering_rental_price]}
    @min_price = @offers.blank? ? 0 : @offers.first.gathering_rental_price
    @max_price = @offers.blank? ? 0 : @offers.last.gathering_rental_price
    @max_price = @max_price.to_f > 10000 ? @max_price : 10000
    respond_to do |format| 
      format.html
      format.js do
        foo = render_to_string(:partial => 'gatherings', :locals => { :gatherings => @offers }).to_json
        render :js => "$('#searched-gatherings-div').html(#{foo});$.setAjaxPagination();"
      end
    end
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


