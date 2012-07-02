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
  match '/search_members' => 'users#search_members'
  match '/search_gatherings' => 'searches#search_gatherings'
  match '/admin_destroy_user/:id' => "admin/users#destroy_user"
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
  
  match "/email_settings/index" => "email_settings#index"
  match "/email_settings/show" => "email_settings#show"
  match "/email_settings/create" => "email_settings#create"
  match "/email_settings/edit" => "email_settings#edit"
  match "/email_settings/update/:id" => "email_settings#update"
  match "/users/delete_account" => "users#delete_account"
  match "/send_resposne_request" => "offers#send_resposne_request"
  match "/send_gathering_deadline/:id" => "offers#send_gathering_deadline"
  match "/update_gathering_deadline" => "offers#update_gathering_deadline"
  match "/pending_gathering_acceptance" => "offers#pending_gathering_acceptance"
     
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
      post "search_gatherings"
      post "search_members"
    end
  end
  
  resources :email_settings do    
  end
  
  #  resources :ratings, :only => [:index, :new, :create, :destroy]
  #match '/rating' => 'businesses#rating', :as => :rating
  #  match '/commenting' => 'businesses#commenting', :as => :commenting
  #  match '/ratings/rate' => 'ratings#rate', :as => :rate
  #match '/show_index_ratings' => 'ratings#show_index_ratings', :as => :show_index_ratings

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
      end      
    end
    resources :users
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

  resources :items do
    collection do
      get "overview"
      get "created_prev_gatherings"
      get "created_coming_gatherings"
      get "pending_gathering_acceptance"
      get "gatherings_at_my_place"
      get "listings_home"
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
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end
  root :to => "home#index"
  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
