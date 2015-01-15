API::Application.routes.draw do
  
  root :to => "home#index"

  devise_for :users, :controllers => {:registrations => "registrations"}

  # get '/workflows/:key' => {:format => 'json'}
  get 'workflows/:key', to: 'workflow#index', defaults: { format: 'json' }  
  get '/workflows/:workflow_id/subjects' => 'subjects#index'
  get '/project' => 'projects#index'
  get '/current_user' => "users#current_user"

  resources :subjects
  resources :classifications, :defaults => { :format => 'json' }
  get  '/current_user' => "users#current_user"
end