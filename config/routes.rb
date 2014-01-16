
	match 'table_it', :to => 'plugin_app#index'

	resources :issues, only: [] do
		member do 
			post :poke
			post :start_time, action: :time, defaults: {time: true}
			post :stop_time, action: :time, defaults: {time: false}
			post :switch_time, action: :time, defaults: {switch: true}
			post :add_time, action: :time
		end
	end
	
	match 'plugin_app/change_to_in_progress', :to => 'plugin_app#change_to_in_progress', :via => [:post]
	match 'plugin_app/start_time', :to => 'plugin_app#start_time', :via => [:post]
	match 'plugin_app/stop_time', :to => 'plugin_app#stop_time', :via => [:post]
	match 'plugin_app/update_issue', :to => 'plugin_app#update_issue', :via => [:post]
	match 'plugin_app/filtr_issues', :to => 'plugin_app#filtr_issue', :via => [:post]
	match 'plugin_app/create_issue', :to => 'plugin_app#create_issue', :via => [:post]
	match 'plugin_app/add_time', :to => 'plugin_app#add_time', :via => [:post]
	match 'plugin_app/uncheck_issue', :to => 'plugin_app#uncheck_issue', :via => [:post]
	match "plugin_app/refresh_issues_list", :to => "plugin_app#refresh_issues_list", :via => [:post, :get]
	match "plugin_app/poke", :to => "plugin_app#poke", :via => [:post]
	match "plugin_app/project_users", :to => "plugin_app#project_users", :via => [:post]
