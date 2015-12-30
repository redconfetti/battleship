class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.boolean :status

      t.timestamps null: false
    end
  end
end
