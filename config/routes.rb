API::Application.routes.draw do
  
  root :to => "home#index"

  devise_for :users, :controllers => {:registrations => "registrations"}

  get '/workflows/:workflow_id/subjects' => 'subjects#index'
  get '/project' => 'projects#index'
  get '/current_user' => "users#current_user"

  # post '/workflows/:workflows_id/classifications'

  resources :classifications, :defaults => { :format => 'json' }
  get  '/current_user' => "users#current_user"
end