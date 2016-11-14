Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/game' => 'pages#game'
  get '/score' => 'pages#score'
end
