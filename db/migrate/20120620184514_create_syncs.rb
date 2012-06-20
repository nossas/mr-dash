class CreateSyncs < ActiveRecord::Migration
  def change
    create_table :syncs do |t|
      t.string :name

      t.timestamps
    end
  end
end
