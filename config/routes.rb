# -*- encoding : utf-8 -*-
PopupStorz::Application.routes.draw do
  get "users/show"
  
  match '/auth/:provider/callback' => 'services#create'
  match '/auth/facebook/callback' => 'services#create'
  match '/auth/twitter/callback' => 'services#create'
  match '/items/search_keyword' => 'items#search_keyword'
  match '/items/search_category/:id' => 'items#search_category'
  match '/notifications/destroy/:id' => 'notifications#destroy'
  match '/members' => 'users#members'
  match '/admin_items' => "admin/items#index"
  match '/admin_gatherings' => "admin/offers#gatherings"
  match '/admin/users/create' => "admin/users#create"
  match '/admin_send_invitations' => "admin/users#send_invitations"
  #  match '/search_members' => 'users#search_members'
  match '/search_gatherings' => 'searches#search_gatherings'
  match '/search_spaces' => 'searches#search_spaces'
  match '/admin_destroy_user/:id' => "admin/users#destroy_user"
  match '/admin_edit_user/:id' => "admin/users#edit"
  match '/admin_users' => "admin/users#index"
  match '/delete_listings' => "admin/items#delete_listings"
  match "/search_via_price_range" => "items#search_via_price_range"
  match "/items/new/:id" => "items#new_comment"
  match "/items/add_comment" => "items#add_comment"
  match "/items/show/:id" => "items#show"
  match "/users/add_comment" => "users#add_comment"
  match "/items/pop_ups" => "items#my_pop_ups"
  match "/home/terms" => "home#terms"
  match "/home/contact" => "home#contact"
  match "/home/feedback" => "home#feedback"
  match "/home/send_feedback" => "home#send_feedback"
  match "/email_settings" => "email_settings#index"
  
  match "/items/payment_charge/:id" => "items#payment_charge"
  match "/home/pay" => "home#pay"
  match "/join_gathering/:id" => "offers#join_gathering"
  match "/join/:id" => "offers#join"
  match "/approve_gathering_request/:id" => "offers#approve_gathering_request"
  match "/decline_gathering_request/:id" => "offers#decline_gathering_request"
  match "/accept_gathering/:id" => "offers#accept"
  match "/reject_gathering/:id" => "offers#decline"
  match "/products/cancelled_payment_request" => "products#cancelled_payment_request", :as  => :cancel_request
  match "products/completed_payment_request" => "products#completed_payment_request", :as => :complete_request
  match "/send_invitation" => "users#send_invitation"
  match "/invitation" => "users#invitations"
  match "/users/callback" => "users#callback"
  match "/users/send_invitation_to_contacts" => "users#send_invitation_to_contacts"
  match "/contacts/failure" => "users#send_invitation_to_contacts"
  
  match "/email_settings/index" => "email_settings#index"
  match "/email_settings/show" => "email_settings#show"
  match "/email_settings/create" => "email_settings#create"
  match "/email_settings/edit" => "email_settings#edit"
  match "/email_settings/update/:id" => "email_settings#update"
  match "/users/deactivate_account" => "users#deactivate_account"
  match "/send_resposne_request" => "offers#send_resposne_request"
  match "/send_gathering_deadline/:id" => "offers#send_gathering_deadline"
  match "/update_gathering_deadline" => "offers#update_gathering_deadline"
  match "/pending_gathering_acceptance" => "offers#pending_gathering_acceptance"
  match "/offers/add_comment" => "offers#add_comment"
  match "/cancel_booking/:id" => "offers#cancel_booking"
  match "/searches/user_rating" => "searches#user_rating"
  
  devise_for :users, :controllers => {:registrations => "registrations"}

  resources :accounts do
    collection do
      get 'verification_selection'
    end
  end

  resources :searches do
    collection do
      get "search_home"
      get "gatherings"
      get "members"
      get "spaces"
      post "search_gatherings"
      post "search_members"
      post "search_spaces"
    end
  end
  
  resources :email_settings do    
  end

  match '/items/set_dates' => "items#set_dates", :as => :set_dates
  match '/items/exchange_price' => "items#exchange_price", :as => :exchange_price

  resources :ratings do
    collection do
      get "rate"
      post "rate"
    end
  end
  
  resources :messages do
    collection do
      get 'inbox'
      get 'compose'
      get 'sent_items'
      get 'trash'      
      get 'delete'
      get 'empty_trash'
      get 'reply'

      post 'do_reply'
      post 'manage'
      post 'send_message'
      post 'contact_me'
      post 'gathering_message'
    end
  end

  match "account/:id/dashboard" => "accounts#dashboard",  :as  => :dashboard
  match "accept_invitation/:id" => "invitations#accept_invitation",  :as  => :accept_invitation
  match '/sign_out' => 'devise/sessions#destroy'

  devise_for :users do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  get "home/index"
  get "home/about"
  get "items/new"
  
  namespace :admin do
    resources :items do
      collection do
        get :change_recommendation
        post :transfer_ownership
        post :change_commission_rate
        get :change_rate
        post :change_all
        post :display_on_home
        get :active_inactive
        get :offer_activation
      end      
    end
    resources :users do
      collection do
        get :delete_message
        get :all_messages
        post :all_messages
        get :all_feedbacks
        post :all_feedbacks
        get :all_ratings
        get :delete_rating
        get :delete_comment
        #        get :send_invitation
        get :invitations
        post :send_invitation_to_users
        post :send_invitations
        post :send_invitation
        get :all_payments
        get :cancel_payment
#        get :all_feedbacks        
      end
    end
    resources :offers do
      collection do
        post :change_commission_rate
        post :add_comment
      end
    end
    resources :messages do
      collection do
        get :send_to_all
        post :send_message_to_all
        post :send_message_to_user
        get :send_message
      end
    end
  end
  resources :services do
    get "/services/create/:id" => "services#create"
  end
  resources :invitations do
    collection do
      get :fetch
      post :fetch
      post :send_emails
    end
  end

  namespace :xml do
    match 'location_search.xml' => 'LocationSearch#index', :format => :xml
    match 'address_search.xml'  => 'AddressSearch#index' , :format => :xml
  end

  resources :ratings do
    collection do
      get "rate"
      post "rate"
    end
  end
  resources :offers
  resources :avatars
  resources :items do
    collection do
      get "overview"
      get "created_prev_gatherings"
      get "created_coming_gatherings"
      get "pending_gathering_acceptance"
      get "gatherings_at_my_place"
      get "listings_home"
      get "past_transactions"
      get "search_item_spaces"
    end
    resources :avatars
    collection do
      get "sent_requests"      
    end
    get :autocomplete_item_title, :on => :collection
    get :autocomplete_item_city, :on => :collection
    get :add_to_favorite, :on => :member
    get :remove_from_favorite, :on => :member
    get :remove_from_favorite_on, :on => :member
    get :favorites, :on => :collection
    resources :offers do
      resources :payments
      member do
        get 'decline'
        get 'accept'
      end
    end
  end
  
  match '/users/:id/profile' => 'users#show', :as => :profile
  match '/users/:id/profile/edit' => 'users#edit', :as => :edit_profile
  match 'admin/users/:id/profile' => 'admin/users#show', :as => :admin_profile
  root :to => "home#index"
end
