class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :celular
      t.datetime :registered_at
      t.string :avatar_url

      t.timestamps
    end
  end
end
