API::Application.routes.draw do

  root :to => "home#index"

  devise_for :users, :controllers => {:registrations => "registrations"}

  get '/projects',        to: 'projects#index', defaults: { format: 'json' }

  get '/workflows',      to: 'workflow#index', defaults: { format: 'json' }
  get '/workflows/:id',  to: 'workflow#show',  defaults: { format: 'json' }

  get '/workflows/:workflow_id/subjects' => 'subjects#index'
  get '/current_user' => "users#current_user"
  get '/subjects/:subject_id', to: 'classifications#show', defaults: { format: 'json'}

  resources :subjects
  resources :classifications, :defaults => { :format => 'json' }
  get  '/current_user' => "users#current_user"
end
