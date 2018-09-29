class CreateStatistics < ActiveRecord::Migration[5.2]
  def change
    create_table :statistics do |t|
      t.references :institution, foreign_key: true
      t.references :region, foreign_key: true
      t.references :statistic_measure, foreign_key: true
      t.integer :value
      t.date :value_date

      t.timestamps
    end
  end
end
