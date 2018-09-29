class CreateStatisticMeasures < ActiveRecord::Migration[5.2]
  def change
    create_table :statistic_measures do |t|
      t.string :code
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
