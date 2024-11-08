Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  devise_for :users, only: [ :sessions ]
  devise_scope :user do
    get "users/sign_up", to: "devise/registrations#new", as: :new_user_registration
    post "users/", to: "devise/registrations#create", as: :user_registration
  end


  get "games_of_life" => "games_of_life#index", as: :gol_index
  post "games_of_life/upload_file" => "games_of_life#post_file_gol", as: :post_file_gol
  post "games_of_life/random_gol" => "games_of_life#post_random_gol", as: :post_random_gol
  post "games_of_life/next_generation" => "games_of_life#post_next_generation", as: :post_next_generation
  root "games_of_life#index"
end
