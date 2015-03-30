# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :release_log_configurations
resources :release_log_queues, :except => [:show]

get '/projects/:project_id/release_logs', :to => 'release_logs#index', :as => :release_logs
get '/projects/:project_id/release_logs/new', :to => 'release_logs#new', :as => :new_release_log
get '/projects/:project_id/release_logs/:id', :to => 'release_logs#show', :as => :release_log
get '/projects/:project_id/release_logs/:id/edit', :to => 'release_logs#edit', :as => :edit_release_log
get '/projects/:project_id/release_logs/:id/clone', :to => 'release_logs#clone', :as => :clone_release_log

get 'release_logs/home', :to => 'release_logs_home#index', :as => :release_logs_home
get 'release_logs/searches', :to => 'release_logs_home#search', :as => :release_logs_search

delete '/projects/:project_id/release_logs/:id', :to => 'release_logs#destroy', :as => :destroy_release_log

post '/projects/:project_id/release_logs', :to => 'release_logs#create'
put '/projects/:project_id/release_logs/:id', :to => 'release_logs#update'

post '/release_log_previews/project/:project_id/release_log', :to => 'release_log_previews#release_log', :as => :preview_release_log
put '/release_log_previews/project/:project_id/:id/release_log', :to => 'release_log_previews#release_log', :as => :preview_existing_release_log

post 'release_log_previews/project/:project_id/release_log/notifications/publish', :to => 'release_log_previews#publish_notification', :as => :preview_publish_notification
put 'release_log_previews/project/:project_id/release_log/:id/notifications/publish', :to => 'release_log_previews#publish_notification', :as => :preview_existing_publish_notification

put 'release_log_previews/project/:project_id/release_log/:id/notifications/rollback', :to => 'release_log_previews#rollback_notification', :as => :preview_rollback_notification
put 'release_log_previews/project/:project_id/release_log/:id/notifications/cancel', :to => 'release_log_previews#cancel_notification', :as => :preview_cancel_notification

put '/release_log_previews/:id/rollback', :to => 'release_log_previews#rollback', :as => :preview_rollback
put '/release_log_previews/:id/cancellation', :to => 'release_log_previews#cancellation', :as => :preview_cancellation

put '/projects/:project_id/release_logs/:id/send_notification/:type', :to => 'release_logs#send_notification', :as => :send_release_log_notification
