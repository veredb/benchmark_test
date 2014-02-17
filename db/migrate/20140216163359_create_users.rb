class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :user_id
      t.integer :node_id
      t.integer :score

      t.timestamps
    end
  end
end
