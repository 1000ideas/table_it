RedmineApp::Application.routes.draw do
  root :to => 'plugin_app#index', :as => 'home'
  match '/', :to => 'plugin_app#index', :as => 'home'
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
end
#ActionController::Routing::Routes.draw do |map|

 # map.connect 'plugin_app/change_to_in_progress', :controller=>'plugin_app', :action=>'change_to_in_progress', :conditions => { :method => :post }
 # map.connect 'plugin_app/start_time', :controller=>'plugin_app', :action=>'start_time', :conditions => { :method => :post }
 # map.connect 'plugin_app/update_issue', :controller=>'plugin_app', :action=>'update_issue', :conditions => { :method => :post }
#  map.connect 'plugin_app/filtr_issues', :controller=>'plugin_app', :action=>'filtr_issues', :conditions => { :method => :post }
 # map.connect 'plugin_app/create_issue', :controller=>'plugin_app', :action=>'create_issue', :conditions => { :method => :post }
 # map.connect 'plugin_app/add_time', :controller=>'plugin_app', :action=>'add_time', :conditions => { :method => :post }
 # map.connect 'plugin_app/uncheck_issue', :controller=>'plugin_app', :action=>'uncheck_issue', :conditions => { :method => :post }
#  map.connect 'plugin_app/refresh_issues_list', :controller=>'plugin_app', :action=>'refresh_issues_list', :conditions => { :method => :post }
#end
