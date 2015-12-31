class ChangeGameStatusDefaultAsPending < ActiveRecord::Migration
  def up
    change_column_default(:games, :status, 'pending')
  end

  def down
    change_column_default(:games, :status, nil)
  end
end
