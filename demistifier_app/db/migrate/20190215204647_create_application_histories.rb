class CreateApplicationHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :application_histories do |t|
      t.references :institution_program_language, foreign_key: true
      t.references :child, foreign_key: true
      t.datetime :load_date
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
      t.integer :riga_queue_position
      t.integer :real_queue_position

      t.timestamps
    end

    Application.all.each do |application|
      ApplicationHistory.create(
        application.attributes.except("id", "sort_index", "created_at", "updated_at").merge(load_date: Date.parse('2019-01-27'))
      )
    end
  end
end
