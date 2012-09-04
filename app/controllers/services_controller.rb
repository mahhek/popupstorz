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
          #          school = omniauth['extra']['raw_info']['education'].first['school'].name ? omniauth['extra']['raw_info']['education'].first['school'].name : ""
          education = omniauth['extra']['raw_info']['education'].collect(&:school).collect(&:name).to_sentence
        else
          education = ""
        end
                
        unless omniauth['extra']['raw_info']['work'].blank?
          #          worked_at = omniauth['extra']['raw_info']['work'].first['employer'].name ? omniauth['extra']['raw_info']['work'].first['employer'].name : ""
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
        #        omniauth['extra']['raw_info']["hometown"]["name"] ? addr = omniauth['extra']['raw_info']["hometown"]["name"] : addr = ''
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
        
        
      elsif service_route == 'twitter'
        email = '' # Twitter API never returns the email address
        omniauth['info']['name'] ? name = omniauth['info']['name'] : name = ''
        user_name = name.split(" ")
        f_name = user_name[0]
        l_name = user_name[1]
        omniauth['uid'] ? uid = omniauth['uid'] : uid = ''
        omniauth['provider'] ? provider = omniauth['provider'] : provider = ''
      else
        render :text => omniauth.to_yaml
        return
      end
      if uid != '' and provider != ''
        if !user_signed_in?
          auth = Service.find_by_provider_and_uid(provider.to_s, uid.to_s)
          if auth
            flash[:notice] = 'Signed in successfully via ' + provider.capitalize + '.'
            unless auth.user.blank?
              sign_in_and_redirect(:user, auth.user)
            else
              redirect_to "/"
            end
            
          else
            if email != '' || (service_route == 'twitter' && name != '')              
              existinguser = User.find_by_email(email)
              if existinguser
                existinguser.services.create(:provider => provider, :uid => uid, :uname => name, :uemail => email)
                flash[:notice] = 'Sign in via ' + provider.capitalize + ' has been added to your account ' + existinguser.email + '. Signed in successfully!'
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
                  flash[:myinfo] = 'Your account on CommunityGuides has been created via ' + provider.capitalize + '. In your profile you can change your personal information and add a local password.'
                  user.confirm!
                  #                  sign_in user
                  session[:fb_user] = user.id
                  redirect_to new_user_registration_path
                  #                  redirect_to edit_user_registration_path
                  #                  user.skip_confirmation!
                  #                  sign_in_and_redirect(:user, user)
                else
                  flash[:myinfo] = "Can't log in. Please try again or later."
                  redirect_to "/"
                end
              end
            else
              flash[:notice] = service_route.capitalize + ' can not be used to sign-up on CommunityGuides as no valid email address has been provided. Please use another authentication provider or use local sign-up. If you already have an account, please sign-in and add ' + service_route.capitalize + ' from your profile.'
              redirect_to "/"
            end
          end
        else
          auth = Service.find_by_provider_and_uid(provider, uid)
          if !auth
            current_user.services.create(:provider => provider, :uid => uid, :uname => name, :uemail => email)
            flash[:notice] = 'Sign in via ' + provider.capitalize + ' has been added to your account.'
            redirect_to services_path
          else
            flash[:notice] = service_route.capitalize + ' is already linked to your account.'
            redirect_to services_path
          end
        end
      else
        flash[:error] = service_route.capitalize + ' returned invalid data for the user id.'
        redirect_to new_user_session_path
      end
    else
      flash[:error] = 'Error while authenticating via ' + service_route.capitalize + '.'
      redirect_to new_user_session_path
    end
  end







end
