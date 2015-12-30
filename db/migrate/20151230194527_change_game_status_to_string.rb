class ChangeGameStatusToString < ActiveRecord::Migration
  def up
    change_column :games, :status, :string
  end

  def down
    change_column :games, :status, 'integer USING CAST(status AS integer)'
  end
end
