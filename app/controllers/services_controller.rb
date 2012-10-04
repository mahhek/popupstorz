# -*- encoding : utf-8 -*-
class ServicesController < ApplicationController
  before_filter :authenticate_user!, :except => [:create]
  def index
    @services = current_user.services.all
  end

  def destroy
    @service = current_user.services.find(params[:id])
    @service.destroy
    redirect_to services_path
  end

  def create   
    request.env['omniauth.auth']['provider'] ? service_route = request.env['omniauth.auth']['provider'] : service_route = 'no service (invalid callback)'
    omniauth = request.env['omniauth.auth']    
    if omniauth and omniauth['provider']
      service_route = omniauth['provider']
      if service_route == 'facebook'
        friends, fb_pic_url,fb_friends_count, birthday, city, country = ""
        unless omniauth['extra']['raw_info']['education'].blank?
          education = omniauth['extra']['raw_info']['education'].collect(&:school).collect(&:name).to_sentence
        else
          education = ""
        end
                
        unless omniauth['extra']['raw_info']['work'].blank?
          worked_at = omniauth['extra']['raw_info']['work'].collect(&:employer).collect(&:name).to_sentence
        else
          worked_at = ""
        end
        
        unless omniauth['extra']['raw_info']['location'].blank?
          city = omniauth['extra']['raw_info']['location']['name'].split(',')[0]
          country = omniauth['extra']['raw_info']['location']['name'].split(',')[1]
        else
          city = ""
          country = ""
        end
        name = omniauth['extra']['raw_info']['name'] ? omniauth['extra']['raw_info']['name'] : ""
        email = omniauth['extra']['raw_info']['email'] ?  omniauth['extra']['raw_info']['email'] :  ''
        f_name = omniauth['extra']['raw_info']['first_name'] ? omniauth['extra']['raw_info']['first_name'] : ''
        l_name = omniauth['extra']['raw_info']['last_name'] ?  omniauth['extra']['raw_info']['last_name'] :  ''
        gender = omniauth['extra']['raw_info']['gender'] ? omniauth['extra']['raw_info']['gender'] : ''
        birthday = omniauth['extra']['raw_info']['birthday'] ? omniauth['extra']['raw_info']['birthday'] : ''
        unless birthday.blank?
          birthday = DateTime.strptime(birthday, "%m/%d/%Y").to_time
        end
        
        if gender == "male" 
          gender = true
        else
          gender = false
        end
        omniauth['extra']['raw_info']['id'] ? uid = omniauth['extra']['raw_info']['id'] : uid = ''
        omniauth['provider'] ? provider = omniauth['provider'] : provider = ''        
        
        graph = Koala::Facebook::GraphAPI.new(omniauth['credentials']['token'])
        friends = graph.get_connections("me", "friends")
        pages = graph.get_connections("me", "accounts")
        pages_name = ""
        pages.each do|page|
          if page == pages.last && pages.size > 1
            pages_name += " and"
          else
            if page != pages.first
              pages_name += " ,"
            end
          end
          unless pages_name.blank?
            unless page["name"].blank?
              pages_name += page["name"]
            end
          else
            unless page["name"].blank?
              pages_name = page["name"]
            end
          end          
        end
        fb_friends_count = friends.size
        fb_pic_url = omniauth['info']['image'] ? omniauth['info']['image'] : ''
      else
        render :text => omniauth.to_yaml
        return
      end
      if uid != '' and provider != ''
        if !user_signed_in?
          auth = Service.find_by_provider_and_uid(provider.to_s, uid.to_s)
          if auth
            flash[:notice] = t(:signed_in) + provider.capitalize + '.'
            unless auth.user.blank?
              if auth.user.is_active == true
                sign_in_and_redirect(:user, auth.user)
              else
                session[:fb_user] = auth.user.id
                flash[:notice] = ""
                redirect_to new_user_registration_path
              end
            else
              redirect_to "/"
            end            
          else
            if email != '' || (service_route == 'twitter' && name != '')              
              existinguser = User.find_by_email(email)
              if existinguser
                existinguser.services.create(:provider => provider, :uid => uid, :uname => name, :uemail => email)
                flash[:notice] = t(:sign_in) + provider.capitalize + t(:added_to_account) + existinguser.email + t(:signin_success)
                sign_in_and_redirect(:user, existinguser)
              else
                #                name = name[0, 39] if name.length > 39 # otherwise our user validation will hit us
                if email.blank?
                  email = "a@a.com"
                end
                user = User.new :email => email, :verify_email => email, :password => 'password', :first_name => f_name, :last_name => l_name, :studied_at => education, :works_at => worked_at, :fb_pic_url => fb_pic_url, :fb_friends_count => fb_friends_count, :gender => gender, :fb_pages => pages_name, :is_active => "0", :city => city, :country => country
                user.services.build(:provider => provider, :uid => uid, :uname => name, :uemail => email)
               
                if user.save( :validate => false )
                  if service_route == 'twitter'
                    user.update_attribute("email",'')
                  end
                  flash[:myinfo] = t(:account_communityguides) + provider.capitalize + t(:change_personal_info)
                  user.confirm!
                  # sign_in user
                  session[:fb_user] = user.id
                  redirect_to new_user_registration_path
                else
                  flash[:myinfo] = t(:cant_login)
                  redirect_to "/"
                end
              end
            else
              flash[:notice] = service_route.capitalize + t(:invalid_email) + service_route.capitalize + t(:profile)
              redirect_to "/"
            end
          end
        else
          auth = Service.find_by_provider_and_uid(provider, uid)
          if !auth
            current_user.services.create(:provider => provider, :uid => uid, :uname => name, :uemail => email)
            flash[:notice] = t(:signed_in) + provider.capitalize + t(:added_to_account)
            redirect_to services_path
          else
            flash[:notice] = service_route.capitalize + t(:already_linked)
            redirect_to services_path
          end
        end
      else
        flash[:error] = service_route.capitalize + t(:invalid_user_id)
        redirect_to new_user_session_path
      end
    else
      flash[:error] = t(:authentication_error) + service_route.capitalize + '.'
      redirect_to new_user_session_path
    end
  end
end