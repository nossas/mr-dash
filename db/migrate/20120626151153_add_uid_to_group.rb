class AddUidToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :uid, :string
  end
end
