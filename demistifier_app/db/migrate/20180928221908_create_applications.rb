class CreateApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :applications do |t|
      t.references :institution_program_language, foreign_key: true
      t.references :child, foreign_key: true
      t.date :registered_date
      t.date :desirable_start_date
      t.boolean :priority_5years_old
      t.boolean :priority_commission
      t.boolean :priority_sibling
      t.boolean :priority_parent_local
      t.boolean :priority_child_local
      t.boolean :private_fin_local
      t.boolean :nanny_fin_local
      t.boolean :choose_not_to_receive

      t.timestamps
    end
  end
end
