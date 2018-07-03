Rails.application.routes.draw do
  root 'promocode#activate'
  post '/activation', to: 'promocode#activation'
  get '/promocodes', to: 'promocode#index'
  get '/promocodes/generate', to: 'promocode#generate'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
