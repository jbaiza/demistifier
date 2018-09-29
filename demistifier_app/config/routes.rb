Rails.application.routes.draw do
  resources :institutions, only: [:index] do
    resources :institution_program_languages, only: [:show]
  end
  resources :children, only: [:show]
  get 'home/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'home#index'
end
