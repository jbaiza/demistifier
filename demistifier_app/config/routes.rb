Rails.application.routes.draw do
  resources :institutions, only: [:index] do
    resources :institution_program_languages, only: [:show]
  end
  resources :children, only: [:show] do
    match 'search', on: :collection, via: [:get, :post]
    get 'hint', on: :collection
  end

  resources :subscribes, only: [:show]
  match "subscribes", to: "subscribe#index", via: [:get]
  match "map", to: "map#show", via: [:get]

  get 'home/index'

  root to: 'home#index'
end
