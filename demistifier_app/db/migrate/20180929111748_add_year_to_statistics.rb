class AddYearToStatistics < ActiveRecord::Migration[5.2]
  def change
    add_column :statistics, :year, :integer
  end
end
