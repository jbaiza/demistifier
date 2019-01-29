Rails.application.routes.draw do
  resources :institutions, only: [:index] do
    resources :institution_program_languages, only: [:show]
  end
  resources :children, only: [:show] do
    match 'search', on: :collection, via: [:get, :post]
    get 'hint', on: :collection
  end

  resources :subscribes, only: [:show]
  # match "subscribes", to: "subscribe#index", via: [:get]
  match "map", to: "map#show", via: [:get]

  get 'home/index'
  get "contacts", to: "contacts#index"

  get "api/applications_with_start_date_in_past", to: "api#applications_with_start_date_in_past"
  get "api/applications_totals", to: "api#applications_totals"

  root to: 'home#index'
end
