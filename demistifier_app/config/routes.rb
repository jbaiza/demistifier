Rails.application.routes.draw do
  resources :institutions, only: [:index] do
    resources :institution_program_languages, only: [:show]
  end
  resources :children, only: [:show] do
    get 'search', on: :collection
  end

  get 'home/index'

  root to: 'home#index'
end
