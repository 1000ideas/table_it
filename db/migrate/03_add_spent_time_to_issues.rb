class AddSpentTimeToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :spent_time, :float, precision: 2, default: 0

    Issue.all.each do |issue|
      sum = issue.time_entries.sum(&:hours)
      issue.update_attribute :spent_time, sum
    end
  end

  def self.down
    remove_column :issues, :spent_time
  end
end
