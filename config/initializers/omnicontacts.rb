require "omnicontacts"

Rails.application.middleware.use OmniContacts::Builder do
  importer :gmail, "891067340249-rbkcgb35anof69qjb5ahjfv1kclhb41q.apps.googleusercontent.com", "IP2zTipdB07r3JkuWFld8GRO", {:redirect_path => "/users/callback"}
  importer :yahoo, "consumer_id", "consumer_secret", {:callback_path => '/users/callback'}
  importer :hotmail, "client_id", "client_secret"
end
