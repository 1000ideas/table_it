class CreateProgresstimes < ActiveRecord::Migration
  def self.up
    create_table :progresstimes do |t|
      t.column :issue_id, :integer
      t.column :start_time, :datetime
      t.column :end_time, :datetime
      t.column :closed, :boolean
    end
  end

  def self.down
    drop_table :progresstimes
  end
end
