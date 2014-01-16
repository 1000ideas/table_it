require 'redmine'
require 'extend_core_classes'
require 'issues_helper_patch'
require 'issues_controller_patch'

Redmine::Plugin.register :table_it do
  name 'TableIt'
  author '1000ideas'
  description 'Watch your issues right from redmine home page'
  version '0.1.1'
  url 'https://github.com/1000ideas/table_it.git'
  author_url 'http://1000i.pl'  

  
  project_module :table_it do
    # permission :home, { :table_it => [:table_it] },:public => true
    permission :time_actions, issues: :time
    permission :poke, issues: :poke
  end
end

RedmineApp::Application.routes.prepend do
  root :to => 'issues#index', :as => 'home'
end