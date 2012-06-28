class AddSyncedAtToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :synced_at, :datetime
  end
end
