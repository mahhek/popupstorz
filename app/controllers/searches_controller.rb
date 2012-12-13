class SearchesController < ApplicationController
  def search_home
  end

  def gatherings
    @sizes = Offer.select("distinct(gathering_rental_price)").where("gathering_rental_price is not NULL").order("gathering_rental_price ASC")
    @start_price = @sizes.first
    @last_price = @sizes.last
    
    @start_price = @start_price.blank? ? 0 : @start_price.gathering_rental_price
    unless @last_price.blank?
      @last_price = @last_price.gathering_rental_price.to_f > 10000 ? @last_price.gathering_rental_price : 10000
    else
      @last_price = 10000
    end
    @users_with_uniq_cities = Item.select("distinct(city)").where("city is not NULL and city != ''")
    @gatherings = Offer.find(:all,:conditions => [ "status != 'Cancelled' and parent_id is NULL and is_gathering = true and persons_in_gathering > 0" ], :order=> "rental_start_date ASC")
    @gatherings = @gatherings.paginate(:page => params[:page], :per_page => 6 )
  end

  def members
    @users_with_uniq_cities = Item.select("distinct(city)").where("city is not NULL and city != ''")
    @users_with_uniq_activites = User.select("distinct(activity)").where("activity is not NULL and activity != ''")
    @members = User.find(:all)
    @members = @members.paginate(:page => params[:page], :per_page => 6 )
  end
  
  def spaces
    session[:start_date] = nil
    session[:end_date] = nil
    conds = "1=1 "
    
    @shareable = Item.select("distinct(is_shareable)")
    
    @sizes = Item.select("distinct(size)").where("size is not NULL").order("size ASC")
    @prices = Item.select("distinct(price)").where("price is not NULL").order("price ASC")
    
    @start_size = @sizes.first.size
    @last_size = @sizes.last.size
    @start_size = @start_size.blank? ? 1 : @start_size.size
    
    @start_price = @items.blank? ? 1 : @items.first.price
    @last_price = @items.blank? ? 1 : @items.last.price
    
    unless @last_size.blank?
      @last_size = @last_size.size.to_f > 10000 ? @last_size.size : 10000
    else
      @last_size = 10000
    end

    @last_price = @last_price.to_f > 10000 ? @last_price : 10000
        
    unless params[:search_from].blank?
      start_time =  DateTime.strptime(params[:search_from], "%m/%d/%Y").to_date      
      conds += " AND (('#{start_time.to_s}' between availability_from and availability_to) OR (available_forever = true))"
    end    
    unless params[:search_to].blank?
      end_time =  DateTime.strptime(params[:search_to], "%m/%d/%Y").to_date
      conds += " AND (('#{end_time.to_s}' between availability_from and availability_to)OR (available_forever = true))"
    end
    
    if !params[:search_from].blank? and !params[:search_to].blank? 
      conds += " AND ( ( ( availability_from between '#{start_time.to_s}' and '#{end_time.to_s}') or ( availability_to between '#{start_time.to_s}' and '#{end_time.to_s}')  ) OR (available_forever = true))"
    end
       
    if conds == "1=1 "
      conds += " AND (('#{Date.today.to_s}' between availability_from and availability_to) OR (available_forever = true))"
    end
        
    unless params[:location].blank?
      conds += " AND (city LIKE " + "'%%" + "#{params[:location]}" + "%%'" +")"
    end
    
    @users_with_uniq_cities = Item.select("distinct(city)").where("city is not NULL and city != ''")
    @types = ListingType.select("distinct(name), id").where("name is not NULL")

    @items = Item.all(:conditions => [ conds ])
    active_items = []
    unless @items.blank?
      @items.each do|item|
        if item.user.is_active == true && item.is_active == true
          active_items << item
        end
      end
    end
    @items = active_items
    @items = @items.paginate(:page => params[:page], :per_page => 6, :order => "created_at DESC" )
    respond_to do |format|
      format.html
      format.js do
        foo = render_to_string(:partial => 'items', :locals => { :items => @items, :params => params }).to_json
        render :js => "$('#searched-items').html(#{foo});$.setAjaxPagination();"
      end
    end
  end

  def search_gatherings
    conds = "status != 'Cancelled' and parent_id is NULL and is_gathering = true and persons_in_gathering > 0 "
    cities = []
    items = ""
    if params[:location] && !params[:location].blank?
      city_conds = "(LOWER(city) LIKE " + "'%%" + params[:location].strip.downcase.to_s+ "%%'" +")"
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
    end
    
    unless params[:search_from].blank?
      start_time =  DateTime.strptime(params[:search_from], "%m/%d/%Y").to_date      
      conds += " AND ('#{start_time.to_s}' between rental_start_date and rental_end_date)"
    end
    
    unless params[:search_to].blank?
      end_time =  DateTime.strptime(params[:search_to], "%m/%d/%Y").to_date
      conds += " AND ('#{end_time.to_s}' between rental_start_date and rental_end_date)"
    end
    
    unless params[:min_price].blank?
      conds += " AND (gathering_rental_price >= '#{params[:min_price]}')"
    end
    
    unless params[:max_price].blank?
      conds += " AND (gathering_rental_price <= '#{params[:max_price]}')"
    end
        
    unless sel_items.blank?
      conds += " AND item_id in(#{items})"
    end
    case params[:sort_option]
    when "1"
      order_by = "is_recommended, gathering_rental_price DESC"
    when "2"
      order_by = "gathering_rental_price DESC"
    when "3"
      order_by = "gathering_rental_price ASC"
    when "4"
      order_by = "created_at DESC"
    when "5"
      order_by = "created_at ASC"
    else
      order_by = "gathering_rental_price ASC"
    end
    @offers = Offer.find(:all,:conditions => [ conds ], :order=> order_by)
    @offers = @offers.paginate(:page => params[:page], :per_page => 6 )
    
    unless @offers.blank?
      @offers = @offers.uniq
    end
   
    @min_price = @offers.blank? ? 0 : @offers.first.gathering_rental_price
    @max_price = @offers.blank? ? 0 : @offers.last.gathering_rental_price
    @max_price = @max_price.to_f > 10000 ? @max_price : 10000

    respond_to do |format| 
      format.html
      format.js do
        foo = render_to_string(:partial => 'gatherings', :locals => { :offers => @offers }).to_json
        render :js => "update_gathering_values('#{params.to_json}');$('#searched-gatherings').html(#{foo});$.setAjaxPagination();"
      end
    end
  end
  
  def search_spaces
    session[:start_date] = nil
    session[:end_date] = nil
    
    @sizes = Item.select("distinct(size)").where("size is not NULL").order("size ASC")
    @types = ListingType.select("distinct(name), id").where("name is not NULL")
    @shareable = Item.select("distinct(is_shareable)")    
    #    Conditions to find booked items in given dates
    conds = "1=1 "
    unless params[:search_from].blank?
      start_time =  DateTime.strptime(params[:search_from], "%m/%d/%Y").to_date      
      conds += " AND ('#{start_time.to_s}' between rental_start_date and rental_end_date)"
    end
    
    unless params[:search_to].blank?
      end_time =  DateTime.strptime(params[:search_to], "%m/%d/%Y").to_date
      conds += " AND ('#{end_time.to_s}' between rental_start_date and rental_end_date)"
    end
    
    if !params[:search_from].blank? and !params[:search_to].blank? 
      conds += " AND ( ( rental_start_date between '#{start_time.to_s}' and '#{end_time.to_s}') or ( rental_end_date between '#{start_time.to_s}' and '#{end_time.to_s}')  )"
    end
    
    if params[:search_from].blank? and params[:search_to].blank?
      conds += " AND (('#{Date.today.to_s}' between rental_start_date and rental_end_date))"
    end
    
    if !params[:search_from].blank? or !params[:search_to].blank? 
      conds += " AND status != 'applied'"
    end
        
    booked_items = []
    unless conds == "1=1 "
      conds += "and parent_id is NULL"
      offers = Offer.find(:all,:conditions => [ conds ])
      offers.each do|offer|
        if params[:location].blank?
          booked_items << offer.item
        else
          booked_items << offer.item(:conditions => ["city LIKE '%#{params[:location]}%'"])
        end
      end
    end    
    #    Conditions on Items search
    item_conds = "1=1 "
    
    unless params[:search_from].blank?
      item_conds += " AND ( ('#{start_time.to_s}' >= availability_from OR '#{start_time.to_s}' <= availability_to) OR (available_forever = true))"
    end
    
    unless params[:search_to].blank?
      item_conds += " AND ( ('#{end_time.to_s}' >= availability_from  OR '#{end_time.to_s}' <= availability_to ) OR (available_forever = true))"
    end
    
    if !params[:min_price].blank? and !params[:max_price].blank?
      item_conds += "AND price >= '#{params[:min_price].to_f}' AND price <= '#{params[:max_price].to_f}'"
    end    
    
    unless params[:location].blank?
      item_conds += " AND (city LIKE " + "'%%" + "#{params[:location]}" + "%%'" +")"
    end
        
    unless params[:min_size].blank?
      item_conds += " AND (size >= '#{params[:min_size].to_i}')"
    end
    
    unless params[:max_size].blank?
      item_conds += " AND (size <= '#{params[:max_size].to_i}')"
    end
        
    unless params["types"].blank?
      count = 0
      type_arr = ""
      params["types"].each do|type|        
        if count == 0
          type_arr += " listing_type_id = '#{type}'"
        else
          type_arr += " OR listing_type_id = '#{type}'"
        end
        count += 1
      end
      item_conds += " AND (#{type_arr})"
    end
    
    if params[:shareable] == "true"
      item_conds += " AND (is_shareable = true)"
    elsif params[:shareable] == "false"
      item_conds += " AND (is_shareable = false)"
    end
    
    case params[:sort_option]
    when "1"
      order_by = "created_at DESC"
    when "2"
      order_by = "price DESC"
    when "3"
      order_by = "price ASC"
    when "4"
      order_by = "created_at DESC"
    else
      order_by = "price ASC"
    end
    
    items = Item.find(:all,:conditions => [ item_conds ], :order => order_by)    

    @items = items - booked_items    
    # Items whose owners are active users
    active_items = []  
    @items.each do|item|
      if item.user.is_active == true && item.is_active == true
        active_items << item
      end
    end
    @items = active_items
    
    if params[:sort_option].blank?
      @items = @items.sort_by{|e| e[:price]}
    end
    @min_price = @items.blank? ? 0 : @items.first.price
    @max_price = @items.blank? ? 0 : @items.last.price
    @max_price = @max_price.to_f > 10000 ? @max_price : 10000
    if params[:sort_option].blank?
      @items = @items.sort_by{|e| e[:size]}
    end
    session[:start_date] = params[:search_from]
    session[:end_date] = params[:search_to]
    @vals = params
    @items = @items.paginate(:page => params[:page], :per_page => 6 )
    respond_to do |format|
      format.html
      format.js do
        foo = render_to_string(:partial => 'items', :locals => { :items => @items }).to_json
        #        unless @items.blank?
        render :js => "update_form_values('#{params.to_json}');$('#searched-items').html(#{foo});$.setAjaxPagination();"
        #        else
        #          render :js => "update_form_values('#{params.to_json}');$('#searched-items-div').html('#{t(:other_search)}');"
        #        end
      end
    end
  end

  def search_members    
    conds = "1=1 "
    unless params[:location].blank?
      conds += " AND (LOWER(city) LIKE " + "'%%" + params[:location].strip.downcase.to_s+ "%%'" + "or LOWER(country) LIKE " + "'%%" +params[:location].strip.downcase.to_s + "%%'" +")"
    end
    unless params["types"].blank?
      count = 0
      type_arr = ""
      params["types"].each do|type|
        if count == 0
          type_arr += " LOWER(activity) = '#{type.downcase.to_s}'"
        else
          type_arr += " OR LOWER(activity) = '#{type.downcase.to_s}'"
        end
        count += 1
      end
      conds += " AND (#{type_arr})"
    end
    
    unless params[:user].blank?
      user = params[:user].split(" ")
      if user[1].blank?
        conds += " AND (LOWER(first_name) LIKE "+ "'%%"+ user[0].strip.downcase.to_s + "%%'" + " or LOWER(last_name) LIKE "  + "'%%" + params[:user].strip.downcase.to_s + "%%'"+ " or LOWER(email) LIKE "  + "'%%" + user[0].strip.downcase.to_s + "%%'" +")"
      else
        conds += " AND ((LOWER(first_name) LIKE "+ "'%%"+ user[0].strip.downcase.to_s + "%%'" + " and LOWER(last_name) LIKE "  + "'%%" + user[1].strip.downcase.to_s + "%%'"+ ") or LOWER(email) LIKE "  + "'%%" +  params[:user].strip.downcase.to_s + "%%'" +")"
      end
    end
    @members = User.find(:all, :conditions => [ conds ])
    @members = @members.paginate(:page => params[:page], :per_page => 6 )
    respond_to do |format|
      format.html
      format.js do
        foo = render_to_string(:partial => 'members', :locals => { :members => @members }).to_json
        render :js => "update_member_values('#{params.to_json}');$('#searched-members').html(#{foo});$.setAjaxPagination();"
      end
    end
  end
end