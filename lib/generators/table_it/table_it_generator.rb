require 'generators/table_it/actions'
    class TableItGenerator < Rails::Generators::Base
      include TableIt::Generators::Actions
      desc "Generator installuje plugin table_it"
      def init
        puts "====================================================="
        puts "             Redmine Table It Installer"
        puts "====================================================="
      end
      def add_gems # :nodoc:
          puts "adding gems"
          gem 'thor'
          gem "will_paginate"
       
        Bundler.with_clean_env do
          run 'bundle install'
        end
      end
      def add_migration
        if(!CustomField.find_by_name("end_time_field_name"))
        custom_field = CustomField.new(
          name: "end_time_field_name", 
          field_format: "string", 
          is_required: 0, 
          is_for_all: 1, 
          is_filter: 0, 
          position: 1, 
          searchable: 0, 
          default_value: nil,
          possible_values: nil,
          editable: 1, visible: 1, multiple: 0,type: "IssueCustomField",)
          if custom_field.save
            custom_field.update_attribute(:type, "IssueCustomField",)
            #Tracker.all.each do |tracker|
            #  CustomFieldsTracker.create(custom_field_id: custom_field.id, tracker_id: tracker.id)
            #end
            puts "Made custom field"
          else
            puts custom_field.errors.inspect
          end
        end
      end
      
      def add_translation
        custom_field = CustomField.find_by_name("Time left")
        
        trans = { "end_time_field_name" => "Time left"}
      
        trans['end_time_field_name'] = "Time left"

        I18n.available_locales.each do |locale|
          translations_file "end_time_field_name", "Time left", locale
        end
        
      end
      
      def change_route
        puts "change root path"
        file = ::Rails.root.join('config', "routes.rb")
        text = File.read(file)
        replace = text.gsub("root :to => 'welcome#index', :as => 'home'", "root :to => 'plugin_app#index', :as => 'home'")
        File.open(file, "w") {|file| file.puts replace}
      end
      
      def run_migrations
        puts "run plugin migrations"
        rake("redmine:plugins:migrate")
      end
      
      def add_to_models
        create_file Rails.root+"config/initializers/table_it_conf.rb", "require 'will_paginate/array'" 
      end
    end
