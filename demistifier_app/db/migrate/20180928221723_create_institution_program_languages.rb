class CreateInstitutionProgramLanguages < ActiveRecord::Migration[5.2]
  def change
    create_table :institution_program_languages do |t|
      t.references :institution, foreign_key: true
      t.string :starting_age
      t.string :language
      t.string :language_en

      t.timestamps
    end
  end
end
