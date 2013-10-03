require 'redmine'

Redmine::Plugin.register :table_it do
  name 'TableIt'
  author 'Ewelina Mijal'
  description 'Watch your issues right from redmine home page'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  
  project_module :table_it do
      permission :home, { :table_it => [:table_it] },:public => true
  end
end
