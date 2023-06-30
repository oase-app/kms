Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  #
  get "/:oase_id/:key_id", to: "keys#show"
  post "/:oase_id", to: "keys#create"
end
