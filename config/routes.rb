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
  
  devise_for :users, :controllers => {:registrations => "registrations"}

  resources :accounts do
    collection do
      get 'verification_selection'
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
    resources :items
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
      get "sent_requests"
    end
    get :autocomplete_item_title, :on => :collection
    get :autocomplete_item_city, :on => :collection
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
