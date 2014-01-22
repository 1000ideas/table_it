namespace :table_it do

  desc "Enable table_it plugin for all existing projects"
  task enable: [:environment] do
    Project.scoped.each do |project|
      project.enable_module!(:table_it)
      project.save
      puts "#{project.name}: #{project.module_enabled?(:table_it) ? "enabled" : "disabled"}"
    end
  end
  
end