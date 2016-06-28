require "#{Rails.root}/app/helpers/issues_helper.rb"
include IssuesHelper
include ActionView::Helpers::UrlHelper

namespace :table_it do
  desc 'Enable table_it plugin for all existing projects'
  task enable: [:environment] do
    Project.scoped.each do |project|
      project.enable_module!(:table_it)
      project.save
      puts "#{project.name}: #{project.module_enabled?(:table_it) ? 'enabled' : 'disabled'}"
    end
  end

  desc "Add parent ID to issue's description"
  task :parent_id do
    issues = Issue.where('id != root_id')
    issues.each do |issue|
      next if issue.id == issue.root_id
      link_to_parent = link_to_issue_show(issue.root_id)
      issue.update_attribute(:description, "#{link_to_parent} #{issue.description}")
    end
  end
end
