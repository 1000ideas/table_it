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
        if(!CustomField.find_by_name("Time left"))
          custom_field = CustomField.new(
            name: "Time left", 
            field_format: "string", 
            is_required: 0, 
            is_for_all: 1, 
            is_filter: 0, 
            position: 1, 
            searchable: 0, 
            default_value: nil,
            possible_values: nil,
            editable: 1, 
            visible: 1,
            multiple: 0,
            type: "IssueCustomField")
          
          if custom_field.save            
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
      
      def run_migrations
        puts "run plugin migrations"
        rake("redmine:plugins:migrate")
      end
      
      def add_to_models
        create_file Rails.root+"config/initializers/table_it_conf.rb", "require 'will_paginate/array'" 
      end
    end
