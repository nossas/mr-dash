class AddProviderIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :provider_id, :integer
  end
end
