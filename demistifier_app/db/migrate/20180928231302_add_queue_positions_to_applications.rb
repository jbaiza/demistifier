class AddQueuePositionsToApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :riga_queue_position, :integer
    add_column :applications, :real_queue_position, :integer
  end
end
