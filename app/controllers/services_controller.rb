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
        unless omniauth['extra']['raw_info']['education'].blank?
          school = omniauth['extra']['raw_info']['education'].first['school'].name ? omniauth['extra']['raw_info']['education'].first['school'].name : ""
        else
          school = ""
        end
        unless omniauth['extra']['raw_info']['work'].blank?
          worked_at = omniauth['extra']['raw_info']['work'].first['employer'].name ? omniauth['extra']['raw_info']['work'].first['employer'].name : ""
        else
          worked_at = ""
        end
        omniauth['extra']['raw_info']['email'] ? email = omniauth['extra']['raw_info']['email'] : email = ''
        omniauth['extra']['raw_info']['first_name'] ? f_name = omniauth['extra']['raw_info']['first_name'] : f_name = ''
        omniauth['extra']['raw_info']['last_name'] ? l_name = omniauth['extra']['raw_info']['last_name'] : l_name = ''
        omniauth['extra']['raw_info']['gender'] ? gender = omniauth['extra']['raw_info']['gender'] : gender = ''
        #        omniauth['extra']['raw_info']["hometown"]["name"] ? addr = omniauth['extra']['raw_info']["hometown"]["name"] : addr = ''
        omniauth['extra']['raw_info']['id'] ? uid = omniauth['extra']['raw_info']['id'] : uid = ''
        omniauth['provider'] ? provider = omniauth['provider'] : provider = ''
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
            sign_in_and_redirect(:user, auth.user)
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
                user = User.new :email => email, :password => 'password', :first_name => f_name, :last_name => l_name, :gender => gender, :school => school, :works_at => worked_at
                user.services.build(:provider => provider, :uid => uid, :uname => name, :uemail => email)

                if user.save
                  if service_route == 'twitter'
                    user.update_attribute("email",'')
                  end
                  flash[:myinfo] = 'Your account on CommunityGuides has been created via ' + provider.capitalize + '. In your profile you can change your personal information and add a local password.'
                  user.confirm!
                  #                  user.skip_confirmation!
                  sign_in_and_redirect(:user, user)
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
