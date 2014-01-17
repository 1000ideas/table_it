	resources :issues, only: [] do
		member do 
			post :poke
			post :start_time, action: :time, defaults: {time: true}
			post :stop_time, action: :time, defaults: {time: false}
			post :switch_time, action: :time, defaults: {switch: true}
			post :add_time, action: :time
			post :close, defaults: {reopen: false}
			post :reopen, action: :close, defaults: {reopen: true}
		end
	end
	
	get :project_users, to: 'issues#project_users'
