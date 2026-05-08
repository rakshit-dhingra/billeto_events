Rails.application.routes.draw do
  root "billetto_events#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :billetto_events, only: [:index, :show] do
    member do
      post :upvote,   controller: :votes
      post :downvote, controller: :votes
    end
  end

  # Clerk auth callbacks
  get  "/sign-in",  to: "sessions#new",    as: :sign_in
  post "/sessions", to: "sessions#create"
  delete "/sessions", to: "sessions#destroy", as: :sign_out
end