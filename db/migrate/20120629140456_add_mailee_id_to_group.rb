class AddMaileeIdToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :mailee_id, :integer
  end
end
