class AddUserIdToProgresstimes < ActiveRecord::Migration
  def change
    add_column :progresstimes, :user_id, :integer
  end
end
