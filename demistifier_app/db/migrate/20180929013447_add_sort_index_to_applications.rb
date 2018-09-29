class AddSortIndexToApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :sort_index, :integer
  end
end
