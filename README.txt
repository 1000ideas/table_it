--INSTALLATION--
0) Add the plugin to plugins
1) Add a custom field (Administration>Custom Fields>Issiues>New custom field)
	-name (i.e. Pozostały czas)
	-format text
	-check trackers all
	-check 'for all projects'
2) Add translation to files (config>locales>*.yml)
pl:
  end_time_field_name: Pozostały czas < same name like in adding custom field
This translation must be included in all local files used by users. Otherwise user won't see this field on his table.

3) set in routes.rb  
	root :to => 'plugin_app#index', :as => 'home'
4) do 
	rake redmine:plugins:migrate
5) add line to issue.rb
	has_many :progresstimes
6) add to Gemfile
	will_paginate
7) and to config/initializers i.e. 30-redmine.rb
	require 'will_paginate/array'