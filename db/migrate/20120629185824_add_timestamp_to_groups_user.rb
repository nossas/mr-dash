class AddTimestampToGroupsUser < ActiveRecord::Migration
  def change
    add_column :groups_users, :created_at, :datetime
    add_column :groups_users, :updated_at, :datetime
  end
end
