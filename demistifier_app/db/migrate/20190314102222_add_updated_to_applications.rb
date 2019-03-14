class AddUpdatedToApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :updated, :boolean
  end
end
