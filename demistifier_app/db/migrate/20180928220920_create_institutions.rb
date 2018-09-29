class CreateInstitutions < ActiveRecord::Migration[5.2]
  def change
    create_table :institutions do |t|
      t.string :name
      t.text :alternate_names
      t.string :reg_nr
      t.string :lr_izm_code
      t.string :address
      t.string :institution_type
      t.string :email
      t.string :url
      t.float :lat
      t.float :lon
      t.integer :institution_id_source
      t.references :region, foreign_key: true

      t.timestamps
    end
  end
end
