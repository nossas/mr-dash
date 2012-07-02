class AddSyncedWithMaileeToGroupsUser < ActiveRecord::Migration
  def change
    add_column :groups_users, :synced_with_mailee, :boolean
  end
end
