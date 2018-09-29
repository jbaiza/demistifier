class AddQueueSizeToInstitutionProgramLanguages < ActiveRecord::Migration[5.2]
  def change
    add_column :institution_program_languages, :queue_size, :integer
  end
end
