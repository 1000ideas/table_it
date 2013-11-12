require 'redmine'

Redmine::Plugin.register :table_it do
  name 'TableIt'
  author 'Ewelina Mijal'
  description 'Watch your issues right from redmine home page'
  version '0.1.0'
  url 'https://github.com/1000ideas/table_it.git'
  author_url 'http://1000i.pl'
  
  project_module :table_it do
      permission :home, { :table_it => [:table_it] },:public => true
  end
end
