API::Application.routes.draw do

  root :to => "home#index"

  devise_for :users, :controllers => {:registrations => "registrations",
                                      :omniauth_callbacks => "omniauth_callbacks",
                                      :sessions => "sessions"}


  get '/projects',                                            to: 'projects#index',       defaults: { format: 'json' }

  get '/workflows',                                           to: 'workflow#index',       defaults: { format: 'json' }
  get '/workflows/:id',                                       to: 'workflow#show',        defaults: { format: 'json' }

  get '/current_user',                                        to: "users#logged_in_user"
  post '/tutorial_complete',                                  to: "users#tutorial_complete"
  
  get '/projects/stats',                                      to: 'projects#stats'

  get '/workflows/:workflow_id/subjects',                     to: 'subjects#index'
  get '/workflows/:workflow_id/subject_sets',                 to: 'subject_sets#index'
  
  # Subjects
  get '/subjects/:subject_id',                                to: 'subjects#show',         defaults: { format: 'json' }
  get '/subjects',                                            to: 'subjects#index',        defaults: { format: 'json' }
  get '/workflows/:workflow_id/subject_sets/:subject_set_id/subjects/:subject_id',    to: 'subject_sets#show',     defaults: { format: 'json' }
  
  # Subject_sets
  resources :subject_sets, only: [:show, :index], :defaults => { :format => 'json' }  # we are using the _url helper for show, so opting to keep this as resources for now
  get '/subject_sets/terms/:field',                           to: 'subject_sets#name_search'
  
  # Classifications
  get '/classifications/terms/:workflow_id/:annotation_key',  to: 'classifications#terms'
  post '/classifications',                                    to: 'classifications#create'  

  resources :groups, only: [:show, :index], :defaults => { :format => 'json' }

  # Final data:
  resources :final_subject_sets, only: [:show, :index], :defaults => { :format => 'json' }
  get '/data/latest',                                         to: 'final_data_exports#latest'
  resources :final_data_exports, only: [:show, :index], path: "/data"

  namespace :admin do
    resources :subject_sets, :subjects, :classifications, :users
    get 'dashboard' => 'dashboard#index'
    get 'data' => 'data#index'
    post 'data' => 'data#index'
    get 'data/download' => 'data#download'
    get 'signin' => 'auth#signin'
    post 'stats/recalculate' => 'dashboard#recalculate_stats'
  end
  get 'admin' => 'admin/dashboard#index'
  
end
