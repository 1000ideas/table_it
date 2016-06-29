namespace :table_it do
  desc 'Enable table_it plugin for all existing projects'
  task enable: [:environment] do
    Project.scoped.each do |project|
      project.enable_module!(:table_it)
      project.save
      puts "#{project.name}: #{project.module_enabled?(:table_it) ? 'enabled' : 'disabled'}"
    end
  end

  task :parent_id do
    Issue.where('id != root_id').each do |issue|
      next if issue.id == issue.root_id
      if (custom_field = issue.custom_field_values.find { |cfv| cfv.custom_field.name =~ /pid/i })
        custom_field.value = issue.root_id
        issue.save
      end
    end
  end
end
