require 'redmine'
require 'table_it/extend_core_classes'
require 'table_it/issues_helper_patch'
require 'table_it/issues_controller_patch'

Redmine::Plugin.register :table_it do
  name 'TableIt'
  author '1000ideas'
  description 'Watch your issues right from redmine home page'
  version '0.2.11'
  url 'https://github.com/1000ideas/table_it.git'
  author_url 'http://1000i.pl'

  settings default: {
      default_users: '{}',
      end_time: 1,
      default_activity: '{}',
      close_status: 5,
      inprogress_status: 2
    }, partial: 'settings/table_it'


  project_module :table_it do
    permission :time_actions, :"table_it/issues" => :time
    permission :poke, :"table_it/issues" => :poke
    permission :close_reopen_issue, :"table_it/issues" => :close
    permission :list_project_users, :"table_it/issues" => :project_users
  end
end

RedmineApp::Application.routes.prepend do
  root :to => 'issues#index', :as => 'home'
end
