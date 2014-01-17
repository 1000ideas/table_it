require 'generators/table_it/actions'
    class TableItGenerator < Rails::Generators::Base
      include TableIt::Generators::Actions
      desc "Generator installuje plugin table_it"
      
      def init
        puts "====================================================="
        puts "             Redmine Table It Installer"
        puts "====================================================="
      end


      def add_custom_field
        if CustomField.where(name: 'end_time').empty?
          custom_field = CustomField.new(
            name: "end_time", 
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
            puts "Made custom field (End time)"
          else
            puts custom_field.errors.inspect
          end
        end
      end
      
      def run_migrations
        rake("redmine:plugins:migrate")
      end
      
    end
