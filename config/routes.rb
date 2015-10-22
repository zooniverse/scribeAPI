API::Application.routes.draw do

  root :to => "home#index"

  devise_for :users, :controllers => {:registrations => "registrations",
                                      :omniauth_callbacks => "omniauth_callbacks",
                                      :sessions => "sessions"}


  get '/projects',                     to: 'projects#index',       defaults: { format: 'json' }

  get '/workflows',                    to: 'workflow#index',       defaults: { format: 'json' }
  get '/workflows/:id',                to: 'workflow#show',        defaults: { format: 'json' }

  get '/current_user',                                        to: "users#logged_in_user"
  post '/tutorial_complete',                                  to: "users#tutorial_complete"
  get '/projects/stats',                                      to: 'projects#stats'
  get '/project/style.css',                                   to: 'projects#project_css',  defaults: { format: 'css' }
  get '/project/custom.js',                                   to: 'projects#project_js',  defaults: { format: 'js' }
  get '/workflows/:workflow_id/subjects',                     to: 'subjects#index'
  get '/workflows/:workflow_id/subject_sets',                 to: 'subject_sets#index'
  get '/subjects/:subject_id',                                to: 'subjects#show',         defaults: { format: 'json' }
  get '/subject_sets/:subject_set_id',                        to: 'subject_sets#show',     defaults: { format: 'json' }
  get '/workflows/:workflow_id/subject_sets/:subject_set_id/subjects/:subject_id',    to: 'subject_sets#show',     defaults: { format: 'json' }
  get '/classifications/terms/:workflow_id/:annotation_key',  to: 'classifications#terms'
  get '/subject_sets/terms/:field',                           to: 'subject_sets#name_search'


  post   '/subjects/:id/favourite',           to: 'favourites#create',     defaults: { format: 'json' }
  post   '/subjects/:id/unfavourite',         to: 'favourites#destroy',    defaults: { format: 'json' }

  resources :subjects, :defaults => { :format => 'json' }
  resources :subject_sets, :defaults => { :format => 'json' }
  resources :classifications, :defaults => { :format => 'json' }
  resources :groups, :defaults => { :format => 'json' }
  # resources :favourites, defaults: {format: 'json'}
  # resources :favourites, only: [:index, :create, :destroy]

  namespace :admin do
    resources :subject_sets, :subjects, :classifications #, :users
    get 'dashboard' => 'dashboard#index'
    get 'data' => 'data#index'
    get 'data/download' => 'data#download'
    get 'signin' => 'auth#signin'
  end
  # get 'admin' => 'admin/dashboard#index'

end
